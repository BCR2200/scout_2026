# Scouting app 2026

This repo is for the 2026 scouting app.

## Requirements

* Sounting app collects data for one team and match at a time. 
* The team and match are selected by the user.
* Once selected, the user can enter data for the team and match.
* Team-match is stored in a database.
* Data is transferred to the central scouting database via the QR code display. 

### UI tabs

#### QR tab

* QR code display is a tab. It displays data collected for that team and match.

#### Auto tab (AKA "Aura tab")

* There is a tab that contains match data pertaining to the auto period.
* It tracks where the robot started on the field
* It tracks whether the robot moved during the auto period.
* It tracks attributes relating to robot climbing in auto (explained in "Scoring robot climbing" section)
* It tracks the volleys scored during the auto period. (explained in "Scoring volleys" section)

#### Teleop tab

* There is a tab that contains match data pertaining to the teleop period.
* It tracks the volleys scored during the teleop period. (explained in "Scoring volleys" section)
* It tracks attributes relating to robot climbing in the teleop period (explained in "Scoring robot climbing" section)

### Reusable components

#### Scoring robot climbing

* It tracks whether the robot climbed during the given period. (ex: auto or teleop)
* It tracks the robot's climb level (1-3)
* It tracks the robot's climb position (Left, Center, Right)

#### Scoring volleys

* At a high level, this component tracks the number of volleys scored during the given period, and each volley's attributes.
* A volley is essentially a set of shots taken by a robot. What is a set of shots? It's kind of up to the user to decide.
* If a robot had ~30 balls in its hopper, it would be considered a "volley" of 30 shots.
* A volley also tracks the percentage of shots that were successful.
* Since the shot rate of many robots is quite high, it is difficult to track the exact number of shots taken. For that 
reason, a volley has two attributes that are tracked: the approximate "fullness" of the hopper (0%, 25%, 50%, 75%, 100%) 
and the percentage of shots that were successful (0%, 25%, 50%, 75%, 100%).
* The volleys widget is a list of volleys, and each volley is a card. There is a button for adding a new volley to the list.
* The volley card contains the approximate fullness of the hopper, and the percentage of shots that were successful, and
a "handle" for re-ordering the volley in the list.
* Swiping left or right on a volley deletes it from the list.