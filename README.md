# A/B Day for Baltimore County Public Schools
A/B Day is an [iOS and watchOS application](https://itunes.apple.com/us/app/b-day-for-baltimore-county/id928756760) [and website](https://cameronbernhardt.com/projects/ab-day/) designed to help students, parents, and teachers keep track of the A/B block schedule for Baltimore County Public Schools. It allows you to input any day in the future or past (as far back as the A/B system has existed) and find out whether it was or will be an A or B day.

You can also receive notifications each morning informing you of what type of day that day will be; it will also inform you of delays or closings if applicable.

Notifications are sent from a server written in Python that maintains a constantly-updated copy of the A/B schedule, and the server pulls from BCPS's website each morning to check for closings and delays. In the event of a closing or delay, the app will automatically send a notification and update the stored schedule to reflect these changes, which can be viewed from the app.
