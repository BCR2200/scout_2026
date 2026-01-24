import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../databasing/provider_service.dart';
import 'package:provider/provider.dart';
/*
 * =================================
 * +++          READ ME          +++
 * =================================
 * 
 * Hey there! Looks like you're investigating the shell I've created for the scouting app.
 * That's pretty nifty, it probably means you either are curious to see how it works or want to modify it.
 * If you are here without much knowledge of how coding with dart/flutter works, I HIGHLY recommend learning
 * more about it, there is a lot more to widgets than you'd expect; I wouldn't even begin to call myself an expert.
 * However, I do find it interesting to learn and explore, so I left some comments here to help aid your goal
 * Happy coding :)
 * 
 * - Cameron Derks
 * 
 */

Color randPrimary() {
  var random = Random();
  var color = Colors.primaries[random.nextInt(Colors.primaries.length)];
  return color;
}

Color randHighlight() {
  var random = Random();
  var color = Colors.accents[random.nextInt(Colors.accents.length)];
  return color;
}

/* ********* FUNCTIONS ********* */

// Just a function to convert bool to 0 or 1 because dart can't
Function boolToInt = (bool value) {
  if (value == true) {
    return 1;
  } else {
    return 0;
  }
};

// Just a function to convert an int to bool (0 is false, rest is true)
Function intToBool = (int value) {
  if (value == 0) {
    return false;
  } else {
    return true;
  }
};

/* ********* NON-WIDGET CLASSES ********* */

// Formatter for inputting numerical text (such as number of fouls)
class NumericalRangeFormatter extends TextInputFormatter {
  // Fields for the input min, max, and if typing zero or special characters (-) is allowed
  final int min;
  final int max;
  final bool allowZero;
  final bool allowSpecialChars;

  // Constructor (where you can input stuff when the class is used)
  NumericalRangeFormatter({
    required this.min,
    required this.max,
    this.allowZero = true, // Default
    this.allowSpecialChars = false, // Default
  });

  // Method to send a TextEditingValue based on the conditions and the new + old values
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is zero and zero isn't allowed, send back the old value
    if ((newValue.text == '0' || newValue.text == '00') && allowZero == false) {
      return oldValue;
    }
    // If the new value has a non-num and no special characters, send back the old value
    else if (RegExp('[^0-9]').hasMatch(newValue.text) && !allowSpecialChars) {
      return oldValue;
    }
    // If the new value is nothing, send back the new value (nothing)
    else if (newValue.text == '') {
      return newValue;
    }
    // If the new value is under the minimum, send back the minimum value
    else if (int.parse(newValue.text) < min) {
      return newValue.copyWith(text: min.toStringAsFixed(2));
    }
    // If the new value is over the max, send back the old value
    else if (int.parse(newValue.text) > max) {
      return oldValue;
    }
    // The new value is completely valid, so send back the new value
    else {
      return newValue;
    }
  } // formatEditUpdate
} // NumericalRangeFormatter

/* ********* STATELESS WIDGETS ********* */

// This widget is a customized container widget, specifically to
// make the round cornered boxes everywhere in the app
class CustomContainer extends StatelessWidget {
  // Color, child, and height are fields that can be null
  final Color? color;
  final Widget? child;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  // Constructor (the this.[variable]s are like widget options)
  const CustomContainer({
    this.color,
    this.child,
    this.height,
    this.width,
    this.borderRadius = 20.0, // Default
    this.margin = const EdgeInsets.all(10.0), // Default
    this.padding = const EdgeInsets.symmetric(vertical: 10.0), // Default
    super.key,
  });

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      width: width, // If height is needed, it is here, but default of null
      height: height, // If height is needed, it is here, but default of null
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          borderRadius,
        ), // Creating the circular corners
        color: color,
      ),
      child: child,
    );
  }
} // CustomContainer

// This widget is the normal text widget, except always bold because I got annoyed typing it
class BoldText extends StatelessWidget {
  // fontSize and color can be null
  final String text;
  final double? fontSize;
  final Color? color;

  // Constructor (the this.[variable]s are like widget options)
  const BoldText({required this.text, this.fontSize, this.color, super.key});

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold, // Setting the text to bold
        fontSize: fontSize,
        color: color,
      ),
    );
  }
} // BoldText

// This widget is for the tabs to allow the switching tabs to be coloured nicely
class ColouredTab extends StatelessWidget {
  final Color color;
  final String text;

  // Constructor (the this.[variable]s are like widget options)
  const ColouredTab({required this.color, required this.text, super.key});

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 1.0,
      ), // Adding extra space above and below to get rid of a line
      decoration: BoxDecoration(
        color: color,

        // Rounding the top left and top right corners
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      alignment: Alignment.center, // Centering the text
      child: BoldText(text: text, fontSize: 15, color: Colors.black87),
    );
  }
} // SpecialTab

/* ********* STATEFUL WIDGETS ********* */

// SettingWidget is the sidebar "drawer" that opens showing info/settings
class SettingsWidget extends StatefulWidget {
  // This is to figure out what tablet it is and set it
  final int scoutIndex;
  final Color? backgroundColour;

  // Constructor
  const SettingsWidget({
    super.key,
    required this.scoutIndex,
    this.backgroundColour,
  });

  // Creating and naming the "state" to tell the widget when to update
  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  // All the options for the scout tablet
  final List<String> _tabletIndex = [
    'Red Left',
    'Blue Left',
    'Red Middle',
    'Blue Middle',
    'Red Right',
    'Blue Right',
  ];

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
          widget.backgroundColour, // Setting colour from constructor
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // Disabling scrolling
        children: [
          // The top of the list, pretty much just the title
          const DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align left
              mainAxisAlignment:
                  MainAxisAlignment.center, // Align centered vertically
              children: [
                BoldText(text: 'Settings', fontSize: 27.5),
                BoldText(text: '& Info', fontSize: 27.5),
              ],
            ),
          ),

          // First list tile, indicating which tablet it is
          ListTile(
            title: const BoldText(text: 'Scout Tablet:', fontSize: 22.5),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BoldText(
                  text: _tabletIndex[widget.scoutIndex],
                  fontSize: 22.5,
                ), // Displaying the name using the array in this class
                const BoldText(
                  text: '(in reference to the driver perspective/livestream)',
                  fontSize: 15,
                ),
              ],
            ),
          ),

          const Divider(), // Spacer
          // Second list tile, 5 quick reminders
          ListTile(
            title: const BoldText(text: 'Quick Reminders:', fontSize: 22.5),
            subtitle: Column(
              spacing: 5.0,
              children: <Widget>[
                BoldText(
                  text: '1. Always ensure you change any red fields',
                  fontSize: 17.5,
                ),
                BoldText(
                  text:
                      '2. Make sure the match name is something like       "McMaster Q40"',
                  fontSize: 17.5,
                ),
                BoldText(
                  text:
                      "3. If you load a match and its data doesn't show up, swap to another tab, wait a bit, then swap back",
                  fontSize: 17.5,
                ),
                BoldText(
                  text:
                      '4. When searching in the match catalog, it is easiest to sort by number',
                  fontSize: 17.5,
                ),
                BoldText(
                  text:
                      '5. If you find an error/bug in the app or have any (good) recommendations, let Cameron D. know on discord',
                  fontSize: 17.5,
                ),
              ],
            ),
          ),

          const Divider(), // Spacer
          // Third list tile, tis but a to-do to fill space
          ListTile(
            // TODO make cycles mode

            // These are under stateless widgets in widget_library.dart
            title: const BoldText(text: 'Change Mode', fontSize: 22.5),

            // Making it tappable but do nothing
            onTap: () {},
          ),

          // Spacer
          const Divider(),

          // Fourth list tile, also just a to-do to fill space
          ListTile(
            // TODO make tutorial juuust in case (make it a pop-up, not new page)

            // These are under stateless widgets in widget_library.dart
            title: const BoldText(text: 'Click For Tutorial', fontSize: 22.5),
            subtitle: const BoldText(text: 'NOT YET AVAILABLE', fontSize: 20),

            // Making it tappable but do nothing
            onTap: () {},
          ),
        ], // children
      ),
    );
  } // Widget build
} // _SettingWidgetState

// This widget is what controls the for input a team number
class TeamSelector extends StatefulWidget {
  const TeamSelector({super.key});

  @override
  State<TeamSelector> createState() => _TeamSelectorState();
}

class _TeamSelectorState extends State<TeamSelector> {
  final String column = 'team';
  final TextEditingController _controller = TextEditingController();
  late int _currentValue;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When this widget is initialized, get, store, and set the latest team number
    _currentValue = Provider.of<ScoutProvider>(context, listen: false).teamNum;
    _controller.text = _currentValue.toString();
  }

  // This runs once when the widget is no longer in use
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose(); // Getting rid of the controller when it is finished being used
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 20.0,
      ), // Adding some spacing to the right
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .center, // Keeping all the widgets squished in the center
        children: [
          // Widget title
          const BoldText(text: 'Team:', fontSize: 35),

          // Sized textfield (to input the team number)
          SizedBox(
            width: 100,
            child: Consumer<ScoutProvider>(
              // The consumer makes this widget update when data changes
              builder: (context, scoutProvider, child) {
                // Setting the text to the team number
                _currentValue = scoutProvider.teamNum;
                _controller.text = _currentValue.toString();

                return TextField(
                  controller: _controller,

                  // Input formatter limits the possible inputs from min to max, and prevents zeroes
                  inputFormatters: [
                    NumericalRangeFormatter(
                      min: 1,
                      max: 99999,
                      allowZero: false,
                    ),
                  ],

                  // Styling the text
                  style: TextStyle(fontFamily: 'FunnelDisplay', fontSize: 30),
                  textAlign: TextAlign.center,
                  decoration:
                      _controller.value.text == '0'
                          ? // If no team number is inputted, it shows up red as a warning
                          InputDecoration(
                            filled: true,
                            fillColor: Colors.red[700],
                          )
                          : InputDecoration(filled: false),

                  // Limits the input keyboard to only numbers, and no symbols
                  keyboardType: TextInputType.numberWithOptions(),

                  // This makes tapping the textbox select all the text by selecting text from start to end
                  onTap:
                      () =>
                          _controller.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _controller.value.text.length,
                          ),

                  // Sends the team number typed to the database when it is changed
                  // If the user deletes the number, it sets it back to 0
                  onChanged: (String value) {
                    value == ''
                        ? _currentValue = 0
                        : _currentValue = int.parse(value);
                    scoutProvider.updateData(column, _currentValue);
                  },
                );
              }, // builder
            ),
          ),
        ], // children
      ),
    );
  } // build
} // _TeamSelectorState

// This widget is the slider for the driver rating
class DriverSlider extends StatefulWidget {
  const DriverSlider({super.key});

  @override
  State<DriverSlider> createState() => _DriverSliderState();
}

class _DriverSliderState extends State<DriverSlider> {
  final String column = 'drive_rating';
  late double _currentSliderValue;
  late bool isDefault;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When this widget is loaded in, the slider value is 1.0 by default,
    // but it will try to get then set the value with the _loadData() method
    _currentSliderValue = 1.0;
    isDefault = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets then sets the slider value from the database
  Future<void> _loadData() async {
    int data = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getIntData(column);

    // If the widget is still active and the data isn't the default value (-1)
    if (mounted && data != -1) {
      setState(() {
        _currentSliderValue = data.toDouble(); // Slider needs it to be a double
      });
    }
    // If the widget is still active and the data is the default value (-1)
    else if (mounted && data == -1) {
      setState(() {
        isDefault = true; // Set it to display as the default
      });
    }
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Use up all the vertical space nicely
      children: <Widget>[
        // Widget title
        Container(
          margin: const EdgeInsets.only(left: 5.0, top: 10.0, right: 5.0),
          child: const BoldText(text: 'Driver Rating', fontSize: 20.0),
        ),

        // Slider (and labels)
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 50.0,
          ), // Spacing at edges
          padding: EdgeInsets.zero, // Vertically ensuring it is squished
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly, // Use up all the horizontal space nicely
            children: [
              // Left label
              const BoldText(text: 'Bad', fontSize: 25.0),

              // Fill up all available space with Expanded slider
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ), // Ensure spacing between labels
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Rounding the corners (for the red)
                    color:
                        isDefault
                            ? Colors.red
                            : null, // If it is the default, display as red
                  ),
                  child: Slider(
                    // Displaying the current value to user in a friendly fashion
                    label: _currentSliderValue.toInt().toString(),
                    inactiveColor: Colors.white,
                    activeColor: Colors.grey[700],

                    // Making it on a scale from 1–10
                    divisions: 9,
                    min: 1.0,
                    max: 10.0,

                    value: _currentSliderValue,

                    // When it is first changed, send the value to the database
                    // and change it to not display as the default
                    onChangeStart: (value) {
                      setState(() {
                        _currentSliderValue = value;
                        Provider.of<ScoutProvider>(
                          context,
                          listen: false,
                        ).updateData(column, _currentSliderValue.toInt());
                        isDefault = false;
                      });
                    },

                    // Sending the current value to the database when changed
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        Provider.of<ScoutProvider>(
                          context,
                          listen: false,
                        ).updateData(column, _currentSliderValue.toInt());
                      });
                    },
                  ),
                ),
              ),

              // Right label
              const BoldText(text: 'Good', fontSize: 25.0),
            ], // children:
          ),
        ),
      ],
    );
  } // build
} // _DriverSliderState

// This widget is the slider for the defence rating
class DefenceSlider extends StatefulWidget {
  const DefenceSlider({super.key});

  @override
  State<DefenceSlider> createState() => _DefenceSliderState();
}

class _DefenceSliderState extends State<DefenceSlider> {
  final String column = 'defence';
  late double _currentSliderValue;
  late bool defencePlayed;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When this widget is loaded in, the slider value is 0.0 by default,
    // but it will try to get then set the value with the _loadData() method
    _currentSliderValue = 0.0;
    defencePlayed = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets then sets the slider value from the database
  Future<void> _loadData() async {
    int data = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getIntData(column);

    // If the widget is still active and the data isn't the default value (-1)
    if (mounted && data != -1) {
      setState(() {
        _currentSliderValue = data.toDouble(); // Slider needs it to be a double
      });
    }
    // If the widget is still active and the data is the default value (-1)
    if (mounted && data > 0) {
      setState(() {
        defencePlayed = true; // Set it to display as there being defence
      });
    }
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Use up all vertical the space nicely
      children: <Widget>[
        // Widget title
        Container(
          margin: const EdgeInsets.only(left: 5.0, top: 10.0, right: 5.0),
          child: const BoldText(text: 'Defence Rating', fontSize: 20.0),
        ),

        // Slider (and labels)
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 50.0,
          ), // Spacing at edges
          padding: EdgeInsets.zero, // Vertically ensuring it is squished
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly, // Use up all the horizontal space nicely
            children: [
              // Left label
              const BoldText(text: 'Bad', fontSize: 25.0),

              // Fill up all available space with Expanded slider
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ), // Ensure spacing between labels
                  child: Slider(
                    // Displaying the current value to user in a friendly fashion
                    label:
                        _currentSliderValue == 0.0
                            ? "No Defence"
                            : // If the minimum, display as no defence
                            _currentSliderValue
                                .toInt()
                                .toString(), // Otherwise show the value
                    inactiveColor: Colors.white,
                    activeColor:
                        defencePlayed
                            ? Colors.grey[700]
                            : Colors.grey[500], // Lighter to show no defence
                    // Making it on a scale from 1–10, and an option of no defence
                    divisions: 10,
                    min: 0.0,
                    max: 10.0,
                    value: _currentSliderValue,

                    // Sending the current value to the database when changed,
                    // and updating whether or not to show "no defence"
                    onChanged: (double value) {
                      setState(() {
                        value == 0.0
                            ? defencePlayed = false
                            : defencePlayed = true;
                        _currentSliderValue = value;
                        Provider.of<ScoutProvider>(
                          context,
                          listen: false,
                        ).updateData(column, _currentSliderValue.toInt());
                      });
                    },
                  ),
                ),
              ),

              // Right label
              const BoldText(text: 'Good', fontSize: 25.0),
            ], // children:
          ),
        ),
      ],
    );
  } // build
} // _DefenceSliderState

enum ClimbPos {left, middle, right}

class ClimbPosSelect extends StatefulWidget {
  const ClimbPosSelect({super.key});

  @override
  State<ClimbPosSelect> createState() => _ClimbPosSelect();
}

class _ClimbPosSelect extends State<ClimbPosSelect> {
  ClimbPos defaultPos = ClimbPos.middle;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ClimbPos>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: randPrimary(),
      ),
      segments: const <ButtonSegment<ClimbPos>>[
        ButtonSegment<ClimbPos>(
          value: ClimbPos.left,
          label: Text('Left'),
        ),
        ButtonSegment<ClimbPos>(
          value: ClimbPos.middle,
          label: Text('Middle'),
        ),
        ButtonSegment<ClimbPos>(
          value: ClimbPos.right,
          label: Text('Right'),
        ),
      ],
      selected: <ClimbPos>{defaultPos},
      onSelectionChanged: (Set<ClimbPos> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          defaultPos = newSelection.first;
        });
      },
    );
  }
}
class TestSlider extends StatefulWidget {
  final String? title;
  final bool useNumbers;
  final List<String>? labels;
  final int divisions;
  final double minVal;
  final double maxVal;
  final Color? activeColor;
  final double? defaultVal;

  const TestSlider({
    required this.divisions,
    required this.minVal,
    required this.maxVal,
    this.useNumbers = true,
    this.title,
    this.labels,
    this.activeColor,
    this.defaultVal,
    super.key,
  });

  @override
  State<TestSlider> createState() => _TestSliderState();
}

class _TestSliderState extends State<TestSlider> {
  late double _currentSliderValue;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When this widget is loaded in, the slider value is 0.0 by default,
    // but it will try to get then set the value with the _loadData() method
    _currentSliderValue =
        widget.defaultVal == null ? widget.minVal : widget.defaultVal!;
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Use up all vertical the space nicely
      children: <Widget>[
        // Widget title
        Text(widget.title!),

        // Slider (and labels)
        // Fill up all available space with Expanded slider
        Expanded(
          child: Container(
            height: 100,
            padding: EdgeInsets.only(
              left: 25,
              right: 15,
            ), // Ensure spacing between labels
            child: Slider(
              // Displaying the current value to user in a friendly fashion
              label:
                  widget.useNumbers
                      ? _currentSliderValue.toInt().toString()
                      : widget.labels![_currentSliderValue.toInt()],
              inactiveColor: Colors.white,
              activeColor:
                  widget.activeColor != null
                      ? widget.activeColor!
                      : Colors.grey[700],

              // Making it on a scale from 1–10, and an option of no defence
              divisions: widget.divisions,
              min: widget.minVal,
              max: widget.maxVal,
              value: _currentSliderValue,

              // Sending the current value to the database when changed,
              // and updating whether or not to show "no defence"
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                  //Provider.of<ScoutProvider>(context, listen: false).updateData(column, _currentSliderValue.toInt());
                });
              },
            ),
          ),
        ),
      ],
    );
  } // build
} // _DefenceS

// This widget is for inputting notes on the match
class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  final String column = 'notes';
  final TextEditingController _controller = TextEditingController();
  late String notesText;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When the widget is loaded in, set the default text to nothing
    notesText = '';
    _controller.text = notesText;

    // Try to get then set the notes text from the database with the _loadData() method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets then sets the notes text from the database
  Future<void> _loadData() async {
    String data = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getStringData(column);

    // If the widget is still active and the data isn't the default value (a space)
    if (mounted && data != ' ') {
      setState(() {
        _controller.text = data;
      });
    }
  }

  // This runs once when the widget is no longer in use
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose(); // Get rid of the controller when it is finished being used
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        BoldText(text: 'Notes', fontSize: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50.0,
          ), // Adding some horizontal spacing
          child: TextField(
            style: const TextStyle(fontFamily: 'FunnelDisplay'),
            controller: _controller,
            textInputAction:
                TextInputAction
                    .done, // Replacing the "enter" key with a "done" key
            // Making the maximum lines displayed 3
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 3,

            // Sending the notes to the database when they are typed
            onChanged: (String value) {
              // If the notes are deleted, set it as a space so it properly tabs in the QR
              // The trim is there to get rid of any leading or trailing spaces
              value == '' ? value = ' ' : value = value.trim();
              Provider.of<ScoutProvider>(
                context,
                listen: false,
              ).updateData(column, value);
            },
          ),
        ),
      ],
    );
  } // build
} // _NotesWidgetState

// This widget is the button that should be underneath the QR to get to the next match easily
class NextMatchWidget extends StatefulWidget {
  final VoidCallback? callback;
  final Color? color;
  final double? width;

  // Constructor (the this.[variable]s are like options for the widget)
  const NextMatchWidget({super.key, this.callback, this.color, this.width});

  @override
  State<NextMatchWidget> createState() => _NextMatchWidgetState();
}

class _NextMatchWidgetState extends State<NextMatchWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: widget.color,
      width: widget.width ?? 500, // Default the width to be 500
      padding: EdgeInsets.all(0), // Get rid of default spacing
      child: TextButton(
        onPressed: () {
          // Getting the current match name
          final scoutProvider = Provider.of<ScoutProvider>(
            context,
            listen: false,
          );
          final currentMatchName = scoutProvider.currentMatch;

          // Regular expression to find the match number (last integer of a string)
          final RegExp regExp = RegExp(r'(\d+)(?!.*\d)');
          final matchNum = regExp.firstMatch(currentMatchName)?.group(0);
          int? matchInt = int.tryParse(matchNum ?? '');

          // If the regex found a number in the string
          if (matchInt != null) {
            // Setting match number to be one greater
            int numDigits = matchNum!.length; // Getting number of digits
            int nameLength = currentMatchName.length - numDigits;
            String matchName = currentMatchName.substring(
              0,
              nameLength,
            ); // Getting match name
            matchInt += 1; // Increasing match number by one
            String newMatchName =
                '$matchName$matchInt'; // Creating the new name with the new number

            // Creating a pop-up to alert the user they clicked next match
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const BoldText(
                    text: 'Confirm Next Match?',
                    fontSize: 40,
                  ),
                  content: BoldText(
                    text: 'The match number will be $matchInt',
                    fontSize: 20,
                  ), // Giving further notice to user
                  actions: [
                    // This cancel button will just pop the dialog
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const BoldText(text: 'Cancel', fontSize: 20),
                    ),

                    // This button will confirm the new match name
                    TextButton(
                      onPressed: () {
                        // Sending new match to the database
                        scoutProvider.setMatch(newMatchName);
                        scoutProvider.insertMatch();

                        // Running callback if it exists
                        if (widget.callback != null) {
                          widget.callback!();
                        }

                        // Popping the dialog
                        Navigator.pop(context);
                      },
                      child: const BoldText(text: 'Confirm', fontSize: 20),
                    ),
                  ], // actions:
                );
              }, // builder:
            ); // showDialog
          } else {
            // Giving a pop-up if there is no number
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const BoldText(
                    text: 'No Number in Match Name',
                    fontSize: 40,
                  ),
                  actions: [
                    // This button will just pop the dialog
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const BoldText(text: 'ok', fontSize: 20),
                    ),
                  ], // actions:
                );
              }, // builder:
            ); // showDialog
          } // else
        }, // onPressed
        // Text for the next match button itself
        child: BoldText(text: "Next Match", fontSize: 35, color: Colors.black),
      ),
    );
  } // build
} // _NextMatchWidgetState

// This widget is what is used to set the current match
class MatchSelector extends StatefulWidget {
  const MatchSelector({super.key});

  @override
  State<MatchSelector> createState() => _MatchSelectorState();
}

class _MatchSelectorState extends State<MatchSelector> {
  late TextEditingController _controller;
  bool isFirstTap = true;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // Set the match name to current match name in database upon widget initialization
    _controller = TextEditingController(
      text: Provider.of<ScoutProvider>(context, listen: false).currentMatch,
    );
  }

  // This runs once when the widget is no longer in use
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose(); // Get rid of the controller once it is finished being used
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title (left side)
        const BoldText(text: 'Match:', fontSize: 35.0),

        // Dropdown button to show all matches, using custom MatchPopUpWidget
        IconButton(
          iconSize: 50,
          icon: Icon(Icons.arrow_drop_down_sharp),
          onPressed:
              () => showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return MatchPopUpWidget(); // See class below for the widget
                },
              ),
        ),

        // Rest of the space is a textfield for the match name
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              right: 5.0,
            ), // Adding small spacing to the right
            child: Consumer<ScoutProvider>(
              builder: (context, scoutProvider, child) {
                // Setting the current match to what it is in the database class
                _controller = TextEditingController(
                  text: scoutProvider.currentMatch,
                );

                return TextField(
                  controller: _controller,

                  // Stylizing text
                  style: const TextStyle(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.left,

                  // Placing cursor at the end of the text on the first tap (easy to change num)
                  onTap: () {
                    if (isFirstTap) {
                      _controller.selection = TextSelection.collapsed(
                        offset: _controller.text.length,
                      );
                      isFirstTap = false; // No longer is the first tap
                    }
                  },
                  onSubmitted: (String matchName) async {
                    isFirstTap =
                        true; // Reset the first tap so the next tap will be the "first"
                    String trimmedName =
                        matchName
                            .trim(); // Get rid of leading and trailing whitespace

                    // Check if they submitted an existing name
                    bool exists = await scoutProvider.checkMatchExists(
                      trimmedName,
                    );
                    if (!exists) {
                      // Doesn't exist

                      // Setting and inserting the match name
                      scoutProvider.setMatch(matchName);
                      scoutProvider.insertMatch();
                    } else if (exists && context.mounted) {
                      // It does exist and the widget is mounted

                      // Sending pop-up to alert the user match name exists
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const BoldText(
                              text: 'Entered Existing Match',
                              fontSize: 40,
                            ),
                            content: const SizedBox(
                              width:
                                  300, // Sizing to keep the alert dialog wide
                              child: BoldText(
                                text:
                                    'Enter new match name, add the entered match name with a "new" in front, or load its data.',
                                fontSize: 20,
                              ),
                            ),
                            actions: [
                              // This button will add the match name with a "new" in front
                              TextButton(
                                onPressed: () {
                                  scoutProvider.setMatch('new $trimmedName');
                                  scoutProvider.insertMatch();
                                  Navigator.pop(context);
                                },
                                child: const BoldText(
                                  text: 'add "new" in front',
                                  fontSize: 20,
                                ), // label
                              ),

                              // This button will load the match data for the match name
                              TextButton(
                                // Sets the match name (but doesn't insert a match)
                                onPressed: () {
                                  scoutProvider.setMatch(trimmedName);
                                  Navigator.pop(context);
                                },
                                child: const BoldText(
                                  text: 'load data',
                                  fontSize: 20,
                                ), // Label
                              ),

                              // This button will just remove the dialog
                              TextButton(
                                // Reset the match name to what it was before being changed
                                onPressed: () {
                                  _controller.text = scoutProvider.currentMatch;
                                  Navigator.pop(context);
                                },
                                child: const BoldText(
                                  text: 'cancel',
                                  fontSize: 20,
                                ), // Label
                              ),
                            ], //actions:
                          );
                        }, // builder:
                      ); // showDialog
                    } // else if (exists && context.mounted)
                  }, // onSubmitted
                );
              }, // builder:
            ),
          ),
        ),
      ], // children:
    );
  } // build
} // _MatchSelectorState

// This widget is the pop-up that loads all the matches from the database
// Is there a more efficient way to do this? Maybe, but I don't feel like figuring it out
class MatchPopUpWidget extends StatefulWidget {
  const MatchPopUpWidget({super.key});

  @override
  State<MatchPopUpWidget> createState() => _MatchPopUpWidgetState();
}

class _MatchPopUpWidgetState extends State<MatchPopUpWidget> {
  late TextEditingController _controller;
  late String searchText;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // Setting the search text to nothing upon initialization
    searchText = '';
    _controller = TextEditingController(text: searchText);
  }

  // // This runs once when the widget is no longer in use
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose(); // Get rid of the controller when it is finished being used
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    // StreamBuilder is used to see the connection state (unless I'm a goofball)
    // If connected, it will give the pop-up, otherwise it shows loading
    // It might actually not be needed, but I haven't felt like testing it
    return StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return SizedBox(
          // Sizing the alert dialog widget
          width: 350,
          height: 600,
          child: AlertDialog(
            title: Row(
              children: [
                BoldText(text: 'Match Catalog'), // Title
                VerticalDivider(),

                // Specific searching input (auto searches when typing)
                Icon(Icons.search),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,

                    // Text stylizing
                    style: const TextStyle(
                      fontFamily: 'FunnelDisplay',
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.left,
                    onChanged: (value) {
                      setState(() {
                        searchText =
                            value; // Just reload the widget with the search
                      });
                    },
                  ),
                ),
              ], // children:
            ),

            // This FutureBuilder is used to show a loading widget until datalist is collected
            content: FutureBuilder(
              future: Provider.of<ScoutProvider>(
                context,
                listen: false,
              ).searchData(searchText),
              builder: (context, snapShot) {
                if (snapShot.connectionState == ConnectionState.done) {
                  // Once finished collecting data
                  return Consumer<ScoutProvider>(
                    builder: (context, scoutProvider, child) {
                      return scoutProvider.scoutItem.isNotEmpty
                          ? // Check if there are any matches
                          // Display matches if there are matches
                          SizedBox(
                            height: 500,
                            width: 300,
                            child: ListView.builder(
                              itemCount:
                                  scoutProvider
                                      .scoutItem
                                      .length, // List length is number of matches
                              itemBuilder: (context, int index) {
                                // Every match is displayed as a Card to give it a little pop
                                return Card(
                                  elevation: 3,
                                  child: ListTile(
                                    style: ListTileStyle.drawer,
                                    textColor: Colors.black,

                                    // Label displays the match name, subtitle of team # for clarification
                                    title: BoldText(
                                      text:
                                          scoutProvider
                                              .scoutItem[index]
                                              .match_name,
                                      fontSize: 20.0,
                                    ),
                                    subtitle: Text(
                                      'TEAM: ${scoutProvider.scoutItem[index].team.toString()}',
                                    ),

                                    // When it is tapped, it will set the match to the tapped tile and close the pop-up
                                    onTap: () {
                                      Provider.of<ScoutProvider>(
                                        context,
                                        listen: false,
                                      ).setMatch(
                                        scoutProvider
                                            .scoutItem[index]
                                            .match_name,
                                      );
                                      Navigator.pop(context);
                                    },

                                    // Delete match button (on each list tile)
                                    leading: IconButton(
                                      icon: Icon(Icons.delete),

                                      // When pressed it will give another pop-up to ask if you're sure
                                      onPressed:
                                          () => showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              final String selectedMatchName =
                                                  scoutProvider
                                                      .scoutItem[index]
                                                      .match_name;
                                              return AlertDialog(
                                                title: const BoldText(
                                                  text: 'Delete?',
                                                  fontSize: 40,
                                                ),

                                                // Letting the user know what match they selected to delete
                                                content: BoldText(
                                                  text:
                                                      'match name: $selectedMatchName',
                                                  fontSize: 20,
                                                ),

                                                actions: [
                                                  // The back-out button
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                        ),
                                                    child: const BoldText(
                                                      text: 'No',
                                                      fontSize: 25,
                                                    ),
                                                  ),

                                                  // The confirm button (deletes the match)
                                                  TextButton(
                                                    onPressed: () {
                                                      scoutProvider.deleteData(
                                                        selectedMatchName,
                                                      );
                                                      scoutProvider.scoutItem
                                                          .remove(
                                                            scoutProvider
                                                                .scoutItem[index],
                                                          );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const BoldText(
                                                      text: 'Yes',
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                ], // actions:
                                              );
                                            }, // builder:
                                          ), // onPressed
                                    ),

                                    // Edit match button (on each list tile)
                                    trailing: IconButton(
                                      icon: Icon(Icons.edit),

                                      // When pressed it will give a pop-up to edit the match name
                                      onPressed:
                                          () => showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              // See the class below for this widget
                                              return MatchRenameWidget(
                                                matchName:
                                                    scoutProvider
                                                        .scoutItem[index]
                                                        .match_name,

                                                // Callback function for when you submit the new match name
                                                onSubmit: (value) {
                                                  scoutProvider.changeMatch(
                                                    scoutProvider
                                                        .scoutItem[index]
                                                        .match_name,
                                                    value,
                                                  );
                                                  scoutProvider
                                                      .scoutItem[index]
                                                      .match_name = value;
                                                },
                                              );
                                            }, // builder:
                                          ), // onPressed
                                    ),
                                  ),
                                );
                              }, // itemBuilder:
                            ),
                          )
                          :
                          // If there are no matches, it will display this instead of the list tiles
                          const SizedBox(
                            // Sized box to dimension the alert dialog
                            height: 500,
                            width: 300,
                            child: Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/noMatches.png',
                                ), // Check the path to see the image :)
                              ),
                            ),
                          );
                    }, // builder:
                  );
                } else {
                  // If it has not yet loaded all the data, it will show it is loading
                  return const SizedBox(
                    // Sized box to dimension the alert dialog
                    width: 300,
                    height: 500,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }, // builder:
            ),
          ),
        );
      }, // builder:
    );
  } // build
} // _MatchPopUpWidgetState

// This widget is the pop-up that changes the match name in the MatchPopUpWidget
class MatchRenameWidget extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final String matchName;

  // Constructor (the this.[variable]'s are like options for the widget)
  const MatchRenameWidget({
    super.key,
    required this.onSubmit,
    required this.matchName,
  });

  @override
  State<MatchRenameWidget> createState() => _MatchRenameWidgetState();
}

class _MatchRenameWidgetState extends State<MatchRenameWidget> {
  late TextEditingController _controller;
  late bool unique;
  late String matchName;

  // This runs once when the widget is initialized
  @override
  void initState() {
    // Upon initialization, match name is the same, so unique is false
    unique = false;

    // Setting the controller name to be the matchName (based on MatchPopUpWidget's selection)
    matchName = widget.matchName;
    _controller = TextEditingController(text: matchName);
    super.initState();
  }

  // This runs once when the widget is no longer in use
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose; // Getting rid of the controller when it is finished being used
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const BoldText(text: 'Enter New Match Name', fontSize: 40),
      content: TextField(
        controller: _controller,

        // Stylizing the text
        style: const TextStyle(fontFamily: 'FunnelDisplay', fontSize: 30),
        textAlign: TextAlign.left,

        onChanged: (value) async {
          // Getting rid of leading & trailing white space for the name
          String trimmedMatchName = value.trim();

          // Checking if the match name exists
          bool exists = await Provider.of<ScoutProvider>(
            context,
            listen: false,
          ).checkMatchExists(trimmedMatchName);

          // Updating the widget to reflect the inputs
          setState(() {
            matchName = trimmedMatchName;
            unique = !exists; // The name is unique if it doesn't already exist
          });
        },
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const BoldText(text: 'Cancel', fontSize: 25),
        ),

        // Submit button
        TextButton(
          onPressed:
              unique
                  ? () => {widget.onSubmit(matchName), Navigator.pop(context)}
                  : // If unique, do the callback function
                  null, // If it isn't unique, it will make it so the button does nothing and grays out
          child: const BoldText(text: 'Submit', fontSize: 25),
        ),
      ], // actions:
    );
  } // build
} // _MatchRenameWidgetState

// This widget is the fairly customizable box with a + and - button to input numbers
// This is one of the two custom input widgets as part of this shell
class NumberInputWidget extends StatefulWidget {
  final String? title;
  final Color? fillColor;
  final int minValue;
  final int maxValue;
  final bool showButtons;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double scale;
  final double buttonScale;
  final VoidCallback? onChanged;
  final String column; // Asking for the database column

  // Constructor (the this.[variable]s are like options for the widget)
  const NumberInputWidget({
    super.key,
    this.title,
    this.fillColor,
    this.minValue = 0,
    this.maxValue = 100,
    this.padding = const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
    this.fontSize = 18,
    this.scale = 1.0,
    this.buttonScale = 2.0,
    this.showButtons = true,
    this.onChanged,
    required this.column, // Required so the data has a place to send
  });

  @override
  State<NumberInputWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  final TextEditingController _controller = TextEditingController();
  late int _currentValue;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // Upon initialization, set the value to 0 (as a default)
    _currentValue = 0;
    _controller.text = _currentValue.toString();

    // Loading in data after the initial building with _loadData method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets and sets the number value in the widget to the data from the database
  Future<void> _loadData() async {
    int data = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getIntData(widget.column);

    // Reload the widget to display data only if it the widget is still displayed (due to async)
    if (mounted) {
      setState(() {
        _currentValue = data;
        _controller.text = _currentValue.toString();
      });
    }
  }

  // This runs once when the widget is no longer in use
  @override
  void dispose() {
    super.dispose();
    _controller
        .dispose(); // Getting rid of the controller once it is finished being used
  }

  // Method to increment the value with the tap of the + button
  void _increment() {
    // Checking if the value isn't too large
    if (_currentValue < widget.maxValue) {
      // Rebuild the widget since it changed
      setState(() {
        _currentValue++;
        _controller.text = _currentValue.toString();
        Provider.of<ScoutProvider>(
          context,
          listen: false,
        ).updateData(widget.column, _currentValue); // Send to database

        // Run onChanged callback if it exists
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
      });
    }
  }

  // Method to decrement the value with the tap of the - button
  void _decrement() {
    // Checking if the value isn't too small
    if (_currentValue > widget.minValue) {
      // Rebuild the widget since it changed
      setState(() {
        _currentValue--;
        _controller.text = _currentValue.toString();
        Provider.of<ScoutProvider>(
          context,
          listen: false,
        ).updateData(widget.column, _currentValue); // Send to database

        // Run onChanged callback if it exists
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
      });
    }
  }

  // Method to deal with keyboard input to change the number
  void _onTextChanged(String value) {
    // Checking what number was inputted
    final int? newValue = int.tryParse(value);

    // Checking if the new value exists (is a number) and is within the bounds
    if (newValue != null &&
        newValue >= widget.minValue &&
        newValue <= widget.maxValue) {
      // Rebuild the widget since it changed
      setState(() {
        _currentValue = newValue;
        Provider.of<ScoutProvider>(
          context,
          listen: false,
        ).updateData(widget.column, _currentValue); // Send to database

        // Run onChanged callback if it exists
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
      });
    }
    // Checking if the input was to delete the number/backspace everything
    else if (value.isEmpty) {
      // Reset to minimum if input is cleared
      setState(() {
        _currentValue = widget.minValue;
        _controller.text = _currentValue.toString();
        Provider.of<ScoutProvider>(
          context,
          listen: false,
        ).updateData(widget.column, _currentValue); // Send to database

        // Run onChanged callback if it exists
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
      });

      // Select all the text (since it shows 0 but the next input should be a number without leading 0's)
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.value.text.length,
      );
    }
  } // _onTextChanged

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding, // Spacing is default of 3 vertical
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimize vertical spacing
        children: [
          // Checking if there is a title, and displaying it if there is
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: BoldText(text: widget.title!, fontSize: widget.fontSize),
            ),

          // The input section, wrapped with a scale for variable sizing
          Transform.scale(
            scale: widget.scale,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Squish everything in the center
              children: [
                // Check if decrement button should be shown
                if (widget.showButtons)
                  Transform.scale(
                    scale: widget.buttonScale, // Scale the button
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: widget.buttonScale * 4.0,
                      ), // Spacing in reference to scale
                      child: IconButton(
                        onPressed:
                            _decrement, // Method defined earlier in class
                        icon: const Icon(Icons.remove), // Remove icon (-)
                      ),
                    ),
                  ),

                // Textfield to show and input the number
                SizedBox(
                  width: 60, // Keeping consistent sizing
                  child: TextField(
                    controller: _controller,
                    inputFormatters: [
                      NumericalRangeFormatter(
                        min: widget.minValue,
                        max: widget.maxValue,
                      ), // Limits input to between min & max
                    ],
                    keyboardType:
                        const TextInputType.numberWithOptions(), // Restricting input to only be numbers
                    // Stylizing text
                    style: const TextStyle(fontFamily: 'FunnelDisplay'),
                    textAlign: TextAlign.center,

                    // Select everything when tapped
                    onTap:
                        () =>
                            _controller.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _controller.value.text.length,
                            ),
                    onChanged:
                        _onTextChanged, // Method defined earlier in class
                    // Decorating box to make it easier to see/interact with
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: widget.fillColor,
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),

                // Check if increment button should be shown
                if (widget.showButtons)
                  Transform.scale(
                    scale: widget.buttonScale, // Scale the button
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: widget.buttonScale * 4.0,
                      ), // Spacing in reference to scale
                      child: IconButton(
                        onPressed:
                            _increment, // Method defined earlier in class
                        icon: const Icon(Icons.add), // add icon (+)
                      ),
                    ),
                  ),
              ], // children:
            ),
          ),
        ], // children:
      ),
    );
  } // build
} // _NumberInputWidgetState

// This widget is the fairly customizable checkbox
// This is one of the two custom input widgets as part of this shell
class LabelledCheckBox extends StatefulWidget {
  final String? title;
  final Color? checkColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double scale;
  final double? width;
  final bool redHighlight;
  final VoidCallback? onChanged;
  final String column; // Asking for the database column

  // Constructor (the this.[variable]s are like options for the widget)
  const LabelledCheckBox({
    this.title,
    this.checkColor,
    this.scale = 2.0,
    this.fontSize = 16.0,
    this.padding = const EdgeInsets.all(3.0),
    this.width,
    this.redHighlight = false,
    this.onChanged,
    super.key,
    required this.column, // Required so the data has a place to send
  });

  @override
  State<LabelledCheckBox> createState() => _LabelledCheckBoxState();
}

class _LabelledCheckBoxState extends State<LabelledCheckBox> {
  late bool isChecked;
  late bool isDefault;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // Set the default parameters upon initialization
    isChecked = false;
    isDefault = false;

    // After initialization, get and set from database using _loadData method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets and sets the checkbox state from the data in the database
  Future<void> _loadData() async {
    int data = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getIntData(widget.column);

    // Reload the widget to display data only if it the widget is still displayed (due to async)
    if (mounted) {
      setState(() {
        // If the data isn't the default value, set the check state using the intToBool function
        if (data != -1) {
          isChecked = intToBool(data);
          isDefault = false;
        }
        // If the data IS the default value and the redHighlight option for the widget is true
        else if (widget.redHighlight && data == -1) {
          isDefault = true;
        }
      });
    }
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      width: widget.width,

      decoration: BoxDecoration(
        color:
            isDefault
                ? Colors.red
                : null, // If it is the default, it will have a red highlight
        borderRadius: BorderRadius.circular(
          10.0,
        ), // Rounding the corners (for if it is highlighted)
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment
                .center, // Squish everything into the center vertically
        children: <Widget>[
          // Display the title only if there is a title
          if (widget.title != null)
            BoldText(text: widget.title!, fontSize: widget.fontSize),

          // The checkbox itself, wrapped with a scale for variable sizing
          Transform.scale(
            scale: widget.scale,

            // Consumer is used so it updates when the database data changes
            child: Consumer<ScoutProvider>(
              builder: (context, scoutProvider, child) {
                // If the widget has a reason to load from the database (onChanged callback exists or redHighlight is true)
                if (widget.onChanged != null || widget.redHighlight) {
                  _loadData(); // Method defined earlier in class
                }

                return Checkbox(
                  activeColor: widget.checkColor,
                  focusColor: widget.checkColor,
                  hoverColor: widget.checkColor,
                  value: isChecked,
                  onChanged: (value) {
                    // Redraw the widget when pressed
                    setState(() {
                      isChecked = value!;
                      isDefault =
                          false; // No longer the default if it got updated
                      scoutProvider.updateData(
                        widget.column,
                        boolToInt(value),
                      ); // Send data to the database

                      // Run callback if it exists
                      if (widget.onChanged != null) {
                        widget.onChanged!();
                      }
                    });
                  }, // onChanged
                );
              }, // builder:
            ),
          ),
        ],
      ),
    );
  } // build
} // _LabelledCheckBoxState

// This widget is a reusable climbing tracker with two sliders:
// - Climb level (0-3, where 0 = no climb)
// - Climb position (Left, Center, Right)
class ClimbWidget extends StatefulWidget {
  final String levelColumn;
  final String positionColumn;
  final String? title;

  const ClimbWidget({
    super.key,
    required this.levelColumn,
    required this.positionColumn,
    this.title,
  });

  @override
  State<ClimbWidget> createState() => _ClimbWidgetState();
}

class _ClimbWidgetState extends State<ClimbWidget> {
  double _climbLevel = 0;
  double _climbPosition = 1; // 0=Left, 1=Center, 2=Right

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      int level = await provider.getIntData(widget.levelColumn);
      int position = await provider.getIntData(widget.positionColumn);

      if (mounted) {
        setState(() {
          _climbLevel = level.toDouble();
          // Position is stored as 1=Left, 2=Center, 3=Right, convert to 0-indexed
          _climbPosition = position > 0 ? (position - 1).toDouble() : 1;
        });
      }
    }
  }

  void _updateLevel(double value) {
    setState(() {
      _climbLevel = value;
    });
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      provider.updateData(widget.levelColumn, value.toInt());
    }
  }

  void _updatePosition(double value) {
    setState(() {
      _climbPosition = value;
    });
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      // Store as 1=Left, 2=Center, 3=Right (1-indexed)
      provider.updateData(widget.positionColumn, value.toInt() + 1);
    }
  }

  String _getLevelLabel(double value) {
    if (value == 0) return 'None';
    return 'Level ${value.toInt()}';
  }

  String _getPositionLabel(double value) {
    switch (value.toInt()) {
      case 0:
        return 'Left';
      case 1:
        return 'Center';
      case 2:
        return 'Right';
      default:
        return 'Center';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: BoldText(
                text: widget.title!,
                fontSize: 24,
                color: Colors.white,
              ),
            ),

          // Climb Level Slider
          Column(
            children: [
              BoldText(
                text: 'Climb Level: ${_getLevelLabel(_climbLevel)}',
                fontSize: 18,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const BoldText(text: 'None', fontSize: 14, color: Colors.white70),
                  Expanded(
                    child: Slider(
                      value: _climbLevel,
                      min: 0,
                      max: 3,
                      divisions: 3,
                      label: _getLevelLabel(_climbLevel),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                      onChanged: _updateLevel,
                    ),
                  ),
                  const BoldText(text: '3', fontSize: 14, color: Colors.white70),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Climb Position Slider (only show if climb level > 0)
          AnimatedOpacity(
            opacity: _climbLevel > 0 ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                BoldText(
                  text: 'Position: ${_getPositionLabel(_climbPosition)}',
                  fontSize: 18,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const BoldText(text: 'L', fontSize: 14, color: Colors.white70),
                    Expanded(
                      child: Slider(
                        value: _climbPosition,
                        min: 0,
                        max: 2,
                        divisions: 2,
                        label: _getPositionLabel(_climbPosition),
                        activeColor: Colors.white,
                        inactiveColor: Colors.white38,
                        onChanged: _climbLevel > 0 ? _updatePosition : null,
                      ),
                    ),
                    const BoldText(text: 'R', fontSize: 14, color: Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data class representing a single volley
class Volley {
  int hopperFullness; // 0, 25, 50, 75, 100
  int shotSuccess;    // 0, 25, 50, 75, 100

  Volley({this.hopperFullness = 50, this.shotSuccess = 50});

  Map<String, dynamic> toJson() => {
    'hopperFullness': hopperFullness,
    'shotSuccess': shotSuccess,
  };

  factory Volley.fromJson(Map<String, dynamic> json) => Volley(
    hopperFullness: json['hopperFullness'] ?? 50,
    shotSuccess: json['shotSuccess'] ?? 50,
  );
}

// A single volley card with fullness and success selectors
class VolleyCard extends StatelessWidget {
  final Volley volley;
  final int index;
  final ValueChanged<int> onFullnessChanged;
  final ValueChanged<int> onSuccessChanged;
  final VoidCallback onDelete;

  const VolleyCard({
    super.key,
    required this.volley,
    required this.index,
    required this.onFullnessChanged,
    required this.onSuccessChanged,
    required this.onDelete,
  });

  Widget _buildPercentageSelector({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    final percentages = [0, 25, 50, 75, 100];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BoldText(text: label, fontSize: 12, color: Colors.black87),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: percentages.map((p) {
            final isSelected = value == p;
            return GestureDetector(
              onTap: () => onChanged(p),
              child: Container(
                width: 36,
                height: 28,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$p%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('volley_$index'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Drag handle
              const Icon(Icons.drag_handle, color: Colors.grey),
              const SizedBox(width: 12),

              // Volley number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),

              // Selectors
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPercentageSelector(
                      label: 'Hopper Fullness',
                      value: volley.hopperFullness,
                      onChanged: onFullnessChanged,
                    ),
                    const SizedBox(height: 8),
                    _buildPercentageSelector(
                      label: 'Shot Success',
                      value: volley.shotSuccess,
                      onChanged: onSuccessChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget that manages a list of volleys with add, reorder, and delete
class VolleyListWidget extends StatefulWidget {
  final String column; // Database column to store volleys JSON
  final String? title;

  const VolleyListWidget({
    super.key,
    required this.column,
    this.title,
  });

  @override
  State<VolleyListWidget> createState() => _VolleyListWidgetState();
}

class _VolleyListWidgetState extends State<VolleyListWidget> {
  List<Volley> _volleys = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      String jsonStr = await provider.getStringData(widget.column);
      if (mounted && jsonStr.isNotEmpty && jsonStr != '[]') {
        try {
          List<dynamic> jsonList = jsonDecode(jsonStr);
          setState(() {
            _volleys = jsonList.map((e) => Volley.fromJson(e)).toList();
          });
        } catch (e) {
          // Invalid JSON, start with empty list
          _volleys = [];
        }
      }
    }
  }

  void _saveData() {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      String jsonStr = jsonEncode(_volleys.map((v) => v.toJson()).toList());
      provider.updateData(widget.column, jsonStr);
    }
  }

  void _addVolley() {
    setState(() {
      _volleys.add(Volley());
    });
    _saveData();
  }

  void _removeVolley(int index) {
    setState(() {
      _volleys.removeAt(index);
    });
    _saveData();
  }

  void _updateFullness(int index, int value) {
    setState(() {
      _volleys[index].hopperFullness = value;
    });
    _saveData();
  }

  void _updateSuccess(int index, int value) {
    setState(() {
      _volleys[index].shotSuccess = value;
    });
    _saveData();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final volley = _volleys.removeAt(oldIndex);
      _volleys.insert(newIndex, volley);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: BoldText(
              text: widget.title!,
              fontSize: 20,
              color: Colors.white,
            ),
          ),

        // Add volley button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: _addVolley,
            icon: const Icon(Icons.add),
            label: const Text('Add Volley'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
          ),
        ),

        // Volley list
        Expanded(
          child: _volleys.isEmpty
              ? Center(
                  child: BoldText(
                    text: 'No volleys recorded',
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                )
              : ReorderableListView.builder(
                  itemCount: _volleys.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    return VolleyCard(
                      key: ValueKey('volley_card_$index'),
                      volley: _volleys[index],
                      index: index,
                      onFullnessChanged: (v) => _updateFullness(index, v),
                      onSuccessChanged: (v) => _updateSuccess(index, v),
                      onDelete: () => _removeVolley(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
