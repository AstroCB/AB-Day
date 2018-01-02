# Dependencies
from datetime import date
import json, re, git
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from bs4 import BeautifulSoup
import ssl

context = ssl.SSLContext(ssl.PROTOCOL_TLSv1)

# Utility functions
def getContents(url):
    req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    return urlopen(req, context=context).read().decode("utf-8")

def updateDates():
    git_direc = "/Users/cameronbernhardt/Desktop/astrocb.github.io/"
    path = git_direc + "projects/ab-day/dates.json"
    repo = git.Repo(git_direc)
    repo.git.pull() # Update directory from remote
    with open(path, "r+") as file:
        # Search & replace with the new "Snow" day
        match_str = "\"" + day_str + "\":\"" + AB_response[day_str] + "\""
        repl_str = "\"" + day_str + "\":\"Snow\""
        new_data = re.sub(match_str, repl_str, file.read())
        # Wipe old file
        file.truncate()
    with open(path, "w") as file:
        # Write new data to the file
        file.write(new_data)
    repo.git.add([path])
    me = git.Actor("Cameron Bernhardt", "cambernhardt@me.com");
    repo.git.commit(m="Update dates.json", author=me)
    repo.git.push()

# Send notification via POST to Heroku server
def sendPush(body, title):
    url = "https://astrocb-push.herokuapp.com/newpush"
    fields = {"appIdentifier": "com.cameronbernhardt.AB", "body": body, "title": title}
    request = Request(url, urlencode(fields).encode())
    return urlopen(request, context=context).read().decode()

# Dates API
AB_response = json.loads(getContents("https://cameronbernhardt.com/projects/ab-day/dates.json"))

# BCPS page
BCPS_response = getContents("http://www.bcps.org/status/")
cleaned_resp = BeautifulSoup(BCPS_response, "html.parser")

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
if AB_response.get(day_str) != None:
    push_string = "Today is a"
    day_type = AB_response[day_str]

    if day_type == "A":
        push_string += "n"

    push_string += " " + day_type + " day."
    title_string = day_type + " Day"

# BCPS parsing and collection
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
    match = re.search(r'All schools opening one hour late\.', status)
    if match != None:
        push_string += " Schools will be opening one hour late." # One hour delay
    match = re.search(r'All schools(?: and offices)?\s(?:are\s|will\s(?:once\sagain\s)?be\s)?closed', status, re.I)
    if match != None:
        push_string = "All schools are closed today."
        title_string = "Schools Closed"
        updateDates() # Update dates.json with the news

print(sendPush(push_string, title_string)) # Returns POST response
