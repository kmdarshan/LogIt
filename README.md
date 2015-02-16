# LogIt
![Alt text](https://github.com/kmdarshan/LogIt/blob/master/screenshots/IMG_5218.PNG "one")
![Alt text](https://github.com/kmdarshan/LogIt/blob/master/screenshots/IMG_5210.PNG "one")
![Alt text](https://github.com/kmdarshan/LogIt/blob/master/screenshots/IMG_5216.PNG "one")
![Alt text](https://github.com/kmdarshan/LogIt/blob/master/screenshots/IMG_5217.PNG "one")

This app logs trips for the user. A trip is what it sounds like, a period of
moving from one location to another, in between periods of being still. The trip log should
contain a sorted list of entries, each consisting of start and end addresses of the trip, the time
at which the trip happened, and how long the trip took to do.

For example, at 1:30 pm the user starts the app at 185 Clara St, and goes for a trip to 568
Brannan St. The trip takes 9 minutes and 14 seconds. 

The log should then show something like
185 Clara St > 568 Brannan St
3:35pm
3:44pm (9 min, 14 sec)

Things to note:

1. If the simulator gives you an error you need to set a default location in the scheme.

Functional requirements

● The log should be fully automated, as seen in the mockups, so that the user does not
have to manually tag when a trip starts or ends, or enter start and end addresses.

● A trip starts whenever the device is moving at more than 10 mph. A trip ends when the
device is still for more than 1 minute.

● Note that you can use the simulator to simulate a mock drive for easy testing under
Debug>
Location>
Freeway Drive.

● Use the Geocoder service to get the addresses of the start and stop locations.

● The ON/OFF switch enables and disables trip logging.

● Logging should be happening even when the phone is locked.
