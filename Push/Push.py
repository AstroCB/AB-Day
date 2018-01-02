"""
Push.py
Cameron Bernhardt

This file consists of the code used to send daily push and Twitter
notifications. It also monitors the BCPS status page for snow day/delays and
updates the A/B database with this information while including it in the
notifications that are sent out to iOS devices and Twitter.
"""

# Dependencies
from datetime import date
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import ssl
import json
import re
import git # Used to update the dates API locally & push to remote
from bs4 import BeautifulSoup # For scraping/parsing the BCPS status page
import twitter # Twitter API wrapper
import credentials # Internal module used for storing Twitter API credentials

# Used to ensure SSL standard for requests (and to allow access to the dates
# file over HTTPS)
CONTEXT = ssl.SSLContext(ssl.PROTOCOL_TLSv1)

# Utility functions
def get_contents(url):
    """
    Grabs the contents of the passed URL and returns a urlopen instance.
    """
    req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    return urlopen(req, context=CONTEXT).read().decode("utf-8")

def update_dates(day_str, day_type):
    """
    Accesses the local git repo containing the list of AB dates and updates
    it with the new information when a snow day is detected via the daily BCPS
    site poll.

    Requires a local clone of the repo containing this information (aka my root
    site repository, as this is where the global copy of dates is stored that
    everything pulls from).

    This is done via the handy git module that is included at the top of this
    file, and the updates are done to my site repo in my own name (so the app
    and all of the other clients will receive the new info on the next pull).
    """
    git_direc = "/home/ec2-user/astrocb.github.io/"
    path = git_direc + "projects/ab-day/dates.json"
    repo = git.Repo(git_direc)
    repo.git.pull() # Update directory from remote to pull latest date info
    with open(path, "r+") as dates_file:
        # Search & replace with the new "Snow" day
        match_str = "\"" + day_str + "\":\"" + day_type + "\""
        repl_str = "\"" + day_str + "\":\"Snow\""
        new_data = re.sub(match_str, repl_str, dates_file.read())
        # Wipe old file
        dates_file.truncate()
    with open(path, "w") as dates_file:
        # Write new data to the file
        dates_file.write(new_data)
    # Commit changes as myself and push to remote to update globally
    repo.git.add([path])
    me = git.Actor("Cameron Bernhardt", "cambernhardt@me.com")
    repo.git.commit(m="Update dates.json", author=me)
    repo.git.push()

def send_push(body, title):
    """
    Sends a notification via POST to my custom push-handling Heroku server
    that is shared by all of my iOS apps.

    For the purposes of this app, the only important thing is that this server
    accepts POST requests containing the app's identifier and a body/title to
    be displayed in the notification.
    """
    url = "https://astrocb-push.herokuapp.com/newpush"
    fields = {"appIdentifier": "com.cameronbernhardt.AB", "body": body, "title": title}
    request = Request(url, urlencode(fields).encode())
    return urlopen(request, context=CONTEXT).read().decode()

def send_tweet(msg):
    """
    Tweets the current status from the @abdaybot Twitter account.

    Account credentials used by the twitter module are pulled from a
    gitignored credentials.py file.
    """

    # Construct the API object to log in
    api = twitter.Api(consumer_key=credentials.consumer_key,
                      consumer_secret=credentials.consumer_secret,
                      access_token_key=credentials.access_key,
                      access_token_secret=credentials.access_secret)

    api.PostUpdate(msg)

def main():
    """
    This will run every morning on weekdays (via cron).

    It loads the dates API from my site (that is shared between all clients
    for this application) and also checks the Baltimore County Public Schools
    status page for any county-wide closings.

    If such a closing is found, the dates API will be updated to reflect the
    closing, and any users with push notifications on will be notified and the
    Twitter bot will tweet the same message.

    Otherwise, a normal notification and tweet will be sent with the
    current type of day (A/B).
    """
    DATE_API = "https://cameronbernhardt.com/projects/ab-day/dates.json"
    BCPS_STATUS_PAGE = "http://www.bcps.org/status/"

    # Load the remote dates file from the site
    ab_response = json.loads(get_contents(DATE_API))

    # BCPS page
    bcps_response = get_contents(BCPS_STATUS_PAGE)
    cleaned_resp = BeautifulSoup(bcps_response, "html.parser")

    # Figure out what today is and format it to check
    today = str(date.today()).split("-")

    # Deal with weird formatting of dates API (padded dates)
    if today[2][0] == "0":
        today[2] = today[2][1]
    if today[1][0] == "0":
        today[1] = today[1][1]

    day_str = today[1] + today[2] + today[0]

    push_string = "" # What will be sent
    title_string = None # Optional new title field for pushes

    # AB parsing and collection
    if ab_response.get(day_str) != None: # Query API response for day type
        push_string = "Today is a"
        day_type = ab_response[day_str]

        if day_type == "A": # Grammar check
            push_string += "n"

        push_string += " " + day_type + " day."
        title_string = day_type + " Day"

    # BCPS parsing and collection
    # This is a raw scrape that is heavily dependent on the current formatting
    # of the BCPS status page and the language typically used to indicate
    # delays and closings. If either of these change, this will break, but it is
    # designed to break in a harmless way that will lead to nothing more than
    # users being notified of the current type of day despite a possible
    # closing or delay that may have gone undetected.
    raw_status = cleaned_resp.find(style="font-size:12pt;color:#cc0000;")
    status = None
    if raw_status != None:
        for line in raw_status:
            status = line

    if status != None and status != "":
        match = re.search(r'All schools opening (\S*) hours late\.', status)
        if match != None:
            if match.group(1):
                push_string += " Schools will be opening " + match.group(1) + " hours late." # n hour Delay
                title_string = "Schools Delayed"
        match = re.search(r'All schools opening one hour late\.', status)
        if match != None:
            push_string += " Schools will be opening one hour late." # One hour delay
            title_string = "Schools Delayed"
        match = re.search(r'All schools(?: and offices)?\s(?:are\s|will\s(?:once\sagain\s)?be\s)?closed', status, re.I)
        if match != None:
            push_string = "All schools are closed today."
            title_string = "Schools Closed"
            update_dates(day_str, day_type) # Update dates.json with the news

    send_tweet(push_string)
    send_push(push_string, title_string)

if __name__ == "__main__":
    main()
