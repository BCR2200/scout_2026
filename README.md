This is the shell designed for the scouting app to make it "easy" to create a new app for beginners.
It contains a solid foundation and a couple of examples to make it a smooth transition into coding in flutter.

The contents of the "shell" are primarily found in the lib folder/directory, where there is: 
A databasing folder (containing the necessary classes for the SQLite database and state management with provider) 
A shell folder (containing the general base of the app + custom widgets as well as an example tab that can be used) and
A main.dart file which is designed to easily integrate new pages into the app

There also are a couple of examples/hints in the pubspec.yaml file

# INSTALLING FLUTTER AND DEPENDENCIES

## Part 1: Installing flutter

When installing flutter to use this scouting app, simply follow the steps on the official Flutter website
https://docs.flutter.dev/tools/android-studio
If you wish to install with VS Code (although I encourage Android Studio since you will need an emulator)
you can follow their steps by clicking the Visual Studio Code tab.

Once you have flutter fully installed (including the SDK), you can now clone this repository

If you do run into any errors, try running flutter doctor -v in a bash terminal to get status info

## Part 2: Installing an emulator

If you haven't already, install android studio https://developer.android.com/studio/install
From there, you'll have to create an emulator to run the app. 
Go to the right sidebar and open Device Manager
Add a new virtual device
Select tablet then click "New hardware profile"
Make the screen size 7 inches and the screen resolution 600x1024
After creating the hardware profile, select it and click next
Choose an API, select the corresponding system image (most recent one should work), and click finish

## Part 3: Installing the dependencies

After you have the cloned repository, run the command "flutter pub get" in a terminal
From there you should have all the required dependencies. 
Try running "flutter pub outdated" to see if any need to be updated with "flutter pub upgrade"

# PROGRAMMING GUIDE

## Testing the app

To run the app, I highly recommend using android studio for its built-in emulator
To do so, you simply navigate to the top bar beside "main.dart" and click the device dropdown
From there, open your emulator, then select it. You can now click the big play button to run it
(If it doesn't show up, try "Restart Flutter Daemon" or manually open the emulator from the right)

While running, there should be a lightning bolt for a "hot reload" and a green circle for a "hot restart" 

## Where to look

When programming in the shell, a lot of the work has already been completed (but feel free to modify!),
so there are mainly two large things that are still required:

### Game Specific Tabs

There already is an example tab/page for the QR, but other tabs (auto, tele-op, endgame, etc.) are needed.
To do so, simply make widgets in a similar fashion to the example QR tab and page (found in lib/shell/qr_tab.dart)
inside the main.dart file, and put them into the "tabs" and "pages" lists in the order you want them.

### SQLite database

In the databasing folder, there are two files you have to modify.
The first is the scout_data.dart file, which holds the SQL database interactions
The areas to modify are the ScoutModel class (add the names for the game specific database columns) 
and the onCreate underneath ATTENTION (once more add the names for the game specific database columns)

The second is the provider_service.dart, which handles the database interaction with the UI
The area to update is the dataList for scoutItem (add the ScoutModel additions)

## Flutter coding/syntax

Since Flutter is likely a new programming language for you, I recommend exploring its online documentation
before you start programming. The shell itself has decent programming notes for you to explore as well.
Luckily, flutter is based on object oriented programming in dart, which is very similar to that of java 
so if you already know object oriented java, you'll have a leg up for flutter

Here are some decent resources to get you started:
https://docs.flutter.dev/get-started/fundamentals/widgets (review how widgets work)
https://docs.flutter.dev/ui/widgets (catalog of the widgets you'll use)
https://www.youtube.com/watch?v=1ukSR1GRtMU&list=PL4cUxeGkcC9jLYyp2Aoh6hcWuxFDX6PBJ (decent video tutorial)

### Using the scout custom widgets

In order to make scout app development simpler, this shell contains a few pre-made widgets.
You can view them in lib/shell/shell_library.dart, but they are as follows:

#### CustomContainer

Essentially a Container widget but simplified and automatically rounded corners.
Parameters:
color
child
height
width
borderRadius
margin
padding

### BoldText

Essentially a Text widget but simplified and always bold
Parameters:
text
fontSize
color

### ColouredTab

This is the widget for the correct tab formatting used in the app
Parameters:
color
text

### DriverSlider

This is the widget for the driver rating (to be used in an end/overall performance page)
No parameters.
Already has a spot in the database.

### DefenceSlider

This is the widget for the defence rating (to be used in an end/overall performance page)
No parameters.
Already has a spot in the database.

### NotesWidget

This is the widget for the written notes of the app (to be used in an end/overall performance page)
No parameters.
Already has a spot in the database.

### NumberInputWidget

This is the main number input widget used in the scouting app.
Parameters:
title
fillColor
minValue
maxValue
showButtons
padding 
fontSize
scale
buttonScale
onChanged
column

### LabelledCheckBox

This is the main checkbox input widget used in the scouting app
Parameters:
title
checkColor
padding
fontSize
scale
width
redHighlight
onChanged
column
