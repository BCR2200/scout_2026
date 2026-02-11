import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class RoundedSquareThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double cornerRadius;

  const RoundedSquareThumbShape({
    this.thumbRadius = 12.0,
    this.cornerRadius = 4.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint =
        Paint()
          ..color = sliderTheme.thumbColor ?? Colors.blue
          ..style = PaintingStyle.fill;

    // Create the square area centered on the slider line
    final rect = Rect.fromCenter(
      center: center,
      width: thumbRadius * 2,
      height: thumbRadius * 2,
    );

    // Draw the rounded rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      paint,
    );
  }
}

class ColorProvider extends ChangeNotifier {
  final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  late int _auraCol;
  late int _teleCol;
  late int _endCol;
  late int _qrCol;

  int get auraCol => _auraCol;
  int get teleCol => _teleCol;
  int get endCol => _endCol;
  int get qrCol => _qrCol;

  ColorProvider() {
    List<Color> usedColors = [];
    _auraCol = randPrimary(exclude: usedColors).value;
    usedColors.add(Color(_auraCol));
    _teleCol = randPrimary(exclude: usedColors).value;
    usedColors.add(Color(_teleCol));
    _endCol = randPrimary(exclude: usedColors).value;
    usedColors.add(Color(_endCol));
    _qrCol = randPrimary(exclude: usedColors).value;
  }

  // Call this during app initialization
  Future<void> loadSettings() async {
    List<Color> usedColors = [];

    int? aura = await _asyncPrefs.getInt('auraCol');
    if (aura != null) {
      _auraCol = aura;
      usedColors.add(Color(aura));
    }

    int? tele = await _asyncPrefs.getInt('teleCol');
    if (tele != null) {
      _teleCol = tele;
      usedColors.add(Color(tele));
    }

    int? end = await _asyncPrefs.getInt('endCol');
    if (end != null) {
      _endCol = end;
      usedColors.add(Color(end));
    }

    int? qr = await _asyncPrefs.getInt('qrCol');
    if (qr != null) {
      _qrCol = qr;
      usedColors.add(Color(qr));
    }

    if (aura == null) {
      _auraCol = randPrimary(exclude: usedColors).value;
      usedColors.add(Color(_auraCol));
    }
    if (tele == null) {
      _teleCol = randPrimary(exclude: usedColors).value;
      usedColors.add(Color(_teleCol));
    }
    if (end == null) {
      _endCol = randPrimary(exclude: usedColors).value;
      usedColors.add(Color(_endCol));
    }
    if (qr == null) {
      _qrCol = randPrimary(exclude: usedColors).value;
    }

    notifyListeners(); // Updates any listening widgets
  }

  Future<void> updateColor(String key, Color newCol) async {
    await _asyncPrefs.setInt(key, newCol.value);
    if (key == 'auraCol') {
      _auraCol = newCol.value;
    } else if (key == 'teleCol') {
      _teleCol = newCol.value;
    } else if (key == 'endCol') {
      _endCol = newCol.value;
    } else if (key == 'qrCol') {
      _qrCol = newCol.value;
    }
    notifyListeners(); // This is what triggers your UI update
  }
}

Color randPrimary({List<Color> exclude = const []}) {
  var random = Random();
  Color color;
  if (Colors.primaries.length <= exclude.length) {
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }
  do {
    color = Colors.primaries[random.nextInt(Colors.primaries.length)];
  } while (exclude.any((c) => c.value == color.value));
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
        fontFamily: 'Red_Hat_Display',
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
              children: <Widget>[
                BoldText(
                  text: '1. Always ensure you change any red fields',
                  fontSize: 17.5,
                ),
                BoldText(
                  text:
                      '2. Make sure the match name is something like\n"McMaster Q40"',
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
                  style: TextStyle(fontFamily: 'Red_Hat_Display', fontSize: 30),
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

class IntakeRating extends StatefulWidget {
  const IntakeRating({super.key});

  @override
  State<IntakeRating> createState() => _IntakeRatingState();
}

class _IntakeRatingState extends State<IntakeRating> {
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
          child: const BoldText(text: 'Intake Consistency', fontSize: 20.0),
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
} // _IntakeratingState

// This widget is the slider for the defence rating
class MainRoleSlider extends StatefulWidget {
  const MainRoleSlider({super.key});

  @override
  State<MainRoleSlider> createState() => _MainRoleSliderState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _MainRoleSliderState extends State<MainRoleSlider> {
  final String column = 'defence';
  final String roleColumn = 'main_role';
  final List<String> list = <String>['Defence', 'Passing', 'Scoring'];
  static late List<MenuEntry> menuEntries;
  late double _currentSliderValue;
  late String _mainRole;
  late bool defencePlayed;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When this widget is loaded in, the slider value is 0.0 by default,
    // but it will try to get then set the value with the _loadData() method
    _currentSliderValue = 0.0;
    _mainRole = list.first;
    menuEntries = UnmodifiableListView<MenuEntry>(
      list.map<MenuEntry>((String name) => MenuEntry(value: name, label: name)),
    );
    defencePlayed = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets then sets the slider value from the database
  Future<void> _loadData() async {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    int data = await provider.getIntData(column);
    String roleData = await provider.getStringData(roleColumn);

    // If the widget is still active and the data isn't the default value (-1)
    if (mounted) {
      setState(() {
        if (data != -1) {
          _currentSliderValue =
              data.toDouble(); // Slider needs it to be a double
        }
        if (data > 0) {
          defencePlayed = true; // Set it to display as there being defence
        }
        if (roleData.isNotEmpty) {
          _mainRole = roleData;
        }
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BoldText(text: 'Main Role:    ', fontSize: 20.0),
            DropdownMenu<String>(
              initialSelection: _mainRole,
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  _mainRole = value!;
                  Provider.of<ScoutProvider>(
                    context,
                    listen: false,
                  ).updateData(roleColumn, _mainRole);
                  if (_mainRole != 'Defence') {
                    Provider.of<ScoutProvider>(
                      context,
                      listen: false,
                    ).updateData(column, _currentSliderValue.toInt());
                    defencePlayed = false;
                  }
                });
              },
              dropdownMenuEntries: menuEntries,
            ),
          ],
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

// This widget is for inputting notes on the match
class NotesWidget extends StatefulWidget {
  final Color UIcol;

  const NotesWidget({required this.UIcol, super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

// This widget is the slider for the Offence rating
class OffenceSlider extends StatefulWidget {
  const OffenceSlider({super.key});

  @override
  State<OffenceSlider> createState() => _OffenceSliderState();
}

class _OffenceSliderState extends State<OffenceSlider> {
  final String column = 'offense';
  late double _currentSliderValue;
  late bool OffencePlayed;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When this widget is loaded in, the slider value is 0.0 by default,
    // but it will try to get then set the value with the _loadData() method
    _currentSliderValue = 0.0;
    OffencePlayed = false;
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
        OffencePlayed = true; // Set it to display as there being Offence
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
          child: const BoldText(text: 'Offence Rating', fontSize: 20.0),
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
                            ? "No Offence"
                            : // If the minimum, display as no Offence
                            _currentSliderValue
                                .toInt()
                                .toString(), // Otherwise show the value
                    inactiveColor: Colors.white,
                    activeColor:
                        OffencePlayed
                            ? Colors.grey[700]
                            : Colors.grey[500], // Lighter to show no Offence
                    // Making it on a scale from 1–10, and an option of no Offence
                    divisions: 10,
                    min: 0.0,
                    max: 10.0,
                    value: _currentSliderValue,

                    // Sending the current value to the database when changed,
                    // and updating whether or not to show "no Offence"
                    onChanged: (double value) {
                      setState(() {
                        value == 0.0
                            ? OffencePlayed = false
                            : OffencePlayed = true;
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
} // _OffenceSliderState

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
        TextField(
          style: const TextStyle(fontFamily: 'Red_Hat_Display'),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            labelText: 'Notes',
            hintText: 'Type...',
            hintStyle: TextStyle(color: widget.UIcol),
            floatingLabelStyle: TextStyle(color: widget.UIcol),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.UIcol),
            ),
          ),

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

class WhoScoutedWidget extends StatefulWidget {
  final Color UIcol;

  const WhoScoutedWidget({required this.UIcol, super.key});

  @override
  State<WhoScoutedWidget> createState() => _WhoScoutedWidgetState();
}

class _WhoScoutedWidgetState extends State<WhoScoutedWidget> {
  final String column = 'who_scouted';
  final TextEditingController _controller = TextEditingController();
  late String whoScoutedText;

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();

    // When the widget is loaded in, set the default text to nothing
    whoScoutedText = '';
    _controller.text = whoScoutedText;

    // Try to get then set the whoScout text from the database with the _loadData() method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // This method gets then sets the whoScout text from the database
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
    return CustomContainer(
      color: Colors.white,
      padding: EdgeInsets.only(top: 5, right: 5, bottom: 5, left: 15),
      margin: EdgeInsets.only(left: 25, right: 25, top: 25),
      borderRadius: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BoldText(text: 'Scouted By:    ', fontSize: 20.0),
          Expanded(
            child: TextField(
              style: const TextStyle(
                fontFamily: 'Red_Hat_Display',
                fontSize: 20,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                labelText: 'Name',
                hintStyle: TextStyle(color: widget.UIcol),
                floatingLabelStyle: TextStyle(color: widget.UIcol),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.UIcol),
                ),
              ),
              controller: _controller,
              textInputAction: TextInputAction
                  .done, // Replacing the "enter" key with a "done" key
              // Making the maximum lines displayed 3
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 1,

              // Sending the whoScout to the database when they are typed
              onChanged: (String value) {
                // If the whoScout are deleted, set it as a space so it properly tabs in the QR
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
      ),
    );
  } // build
} // _WhoScoutedWidgetState

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

        // Title (left side)
        const BoldText(text: 'Match:  ', fontSize: 35.0),

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
                    fontFamily: 'Red_Hat_Display',
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

  // This runs once when the widget is initialized
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScoutProvider>(context, listen: false).searchData('');
    });
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
                  fontFamily: 'Red_Hat_Display',
                  fontSize: 20,
                ),
                textAlign: TextAlign.left,
                onChanged: (value) {
                  Provider.of<ScoutProvider>(
                    context,
                    listen: false,
                  ).searchData(value);
                },
              ),
            ),
          ], // children:
        ),
        content: Consumer<ScoutProvider>(
          builder: (context, scoutProvider, child) {
            if (scoutProvider.isLoading) {
              return const SizedBox(
                // Sized box to dimension the alert dialog
                width: 300,
                height: 500,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return scoutProvider.scoutItem.isNotEmpty
                ? // Check if there are any matches
                // Display matches if there are matches
                SizedBox(
                  height: 500,
                  width: 300,
                  child: ListView.builder(
                    itemCount: scoutProvider.scoutItem.length,
                    itemBuilder: (context, int index) {
                      return Card(
                        elevation: 3,
                        child: ListTile(
                          style: ListTileStyle.drawer,
                          textColor: Colors.black,
                          title: BoldText(
                            text: scoutProvider.scoutItem[index].match_name,
                            fontSize: 20.0,
                          ),
                          subtitle: Text(
                            'TEAM: ${scoutProvider.scoutItem[index].team.toString()}',
                          ),
                          onTap: () {
                            Provider.of<ScoutProvider>(
                              context,
                              listen: false,
                            ).setMatch(
                              scoutProvider.scoutItem[index].match_name,
                            );
                            Navigator.pop(context);
                          },
                          leading: IconButton(
                            icon: Icon(Icons.delete),
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
                                      content: BoldText(
                                        text: 'match name: $selectedMatchName',
                                        fontSize: 20,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const BoldText(
                                            text: 'No',
                                            fontSize: 25,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            scoutProvider.deleteData(
                                              selectedMatchName,
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const BoldText(
                                            text: 'Yes',
                                            fontSize: 25,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed:
                                () => showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MatchRenameWidget(
                                      matchName:
                                          scoutProvider
                                              .scoutItem[index]
                                              .match_name,
                                      onSubmit: (value) {
                                        scoutProvider.changeMatch(
                                          scoutProvider
                                              .scoutItem[index]
                                              .match_name,
                                          value,
                                        );
                                      },
                                    );
                                  },
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                )
                : const SizedBox(
                  height: 500,
                  width: 300,
                  child: Center(
                    child: Image(image: AssetImage('assets/noMatches.png')),
                  ),
                );
          },
        ),
      ),
    );
  }
}

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
        style: const TextStyle(fontFamily: 'Red_Hat_Display', fontSize: 30),
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
                    style: const TextStyle(fontFamily: 'Red_Hat_Display'),
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

class ClimbWidget extends StatefulWidget {
  final bool isAuto;
  final Color pageColor;

  const ClimbWidget({required this.isAuto, required this.pageColor, super.key});

  @override
  State<ClimbWidget> createState() => _ClimbWidgetState();
}

class _ClimbWidgetState extends State<ClimbWidget> {
  late double _climbLevel;
  late int _climbSide;
  late String _posColumn;
  late String _levelColumn;

  @override
  void initState() {
    super.initState();

    _climbLevel = 0.0;
    _climbSide = 1;
    _posColumn = widget.isAuto ? 'auto_climb_position' : 'climb_position';
    _levelColumn = widget.isAuto ? 'auto_climb_level' : 'climb_level';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevel();
      _loadPos();
    });
  }

  Future<void> _loadLevel() async {
    int initLevel = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getIntData(_levelColumn);

    // If the widget is still active and the data isn't the default value (a space)
    if (mounted && initLevel != 0) {
      setState(() {
        _climbLevel = initLevel.toDouble();
      });
    }
  }

  Future<void> _loadPos() async {
    int initPos = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getIntData(_posColumn);

    // If the widget is still active and the data isn't the default value (a space)
    if (mounted && initPos != -1) {
      setState(() {
        _climbSide = initPos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.all(25),
      child: Row(
        children: [
          BoldText(text: "Climb\nStatus", fontSize: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const BoldText(text: 'Climb Level'),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 10,
                    thumbShape: const RoundedSquareThumbShape(),
                    overlayColor: Colors.transparent,
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTickMarkColor: Colors.transparent,
                    inactiveTickMarkColor: Colors.transparent,
                    valueIndicatorShape: RoundedRectSliderValueIndicatorShape(),
                    thumbColor: widget.pageColor,
                    valueIndicatorColor: widget.pageColor,
                    activeTrackColor: widget.pageColor.withOpacity(0.5),
                    inactiveTrackColor: widget.pageColor.withOpacity(0.5),
                  ),
                  child: Slider(
                    label:
                        _climbLevel == 0
                            ? "No Climb"
                            : _climbLevel.toInt().toString(),
                    divisions: 3,
                    min: 0.0,
                    max: 3.0,
                    value: _climbLevel,
                    onChanged: (double value) {
                      setState(() {
                        _climbLevel = value;
                        Provider.of<ScoutProvider>(
                          context,
                          listen: false,
                        ).updateData(_levelColumn, _climbLevel.toInt());
                      });
                    },
                  ),
                ),
                const BoldText(text: "Climb Side"),
                const SizedBox(height: 4),
                Opacity(
                  opacity: _climbLevel == 0 ? 0.3 : 1,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: widget.pageColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    segments: const <ButtonSegment<int>>[
                      ButtonSegment<int>(value: 0, label: Text('Left')),
                      ButtonSegment<int>(value: 1, label: Text('Middle')),
                      ButtonSegment<int>(value: 2, label: Text('Right')),
                    ],
                    selected: <int>{_climbSide},
                    onSelectionChanged: (Set<int> newSelection) {
                      if (_climbLevel != 0) {
                        setState(() {
                          _climbSide = newSelection.first;
                          Provider.of<ScoutProvider>(
                            context,
                            listen: false,
                          ).updateData(_posColumn, _climbSide);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VolleyListItem extends StatefulWidget {
  final Color color;
  final Color? UIcol;
  final bool isBlue;
  final List<dynamic> item;
  final ValueChanged<String> onTypeChange;
  final ValueChanged<int> onHopChange;
  final ValueChanged<int> onAccChange;
  final ValueChanged<int> onSideChange;
  final VoidCallback onDelete;

  const VolleyListItem({
    this.color = Colors.white,
    required this.isBlue,
    required this.item,
    this.UIcol,
    required this.onTypeChange,
    required this.onAccChange,
    required this.onHopChange,
    required this.onSideChange,
    required this.onDelete,
    super.key,
  });

  @override
  State<VolleyListItem> createState() => _VolleyListItem();
}

class _VolleyListItem extends State<VolleyListItem> {
  late int _percentHopper;
  late int _percentAcc;
  late int _mainSide;
  late String _volleyType;
  late Color _UIcol;
  final List<String> typeList = <String>['volley', 'harvest', 'pass'];
  final List<ButtonSegment<int>> _percents = List<ButtonSegment<int>>.generate(
    5,
    (index) {
      return ButtonSegment<int>(
        value: (index + 5) * 10,
        label: Text('${(index + 5) * 10}', style: TextStyle(fontSize: 10)),
      );
    },
  );

  @override
  void initState() {
    super.initState();

    _percents.insert(
      0,
      ButtonSegment<int>(
        value: 25,
        label: Text('25', style: TextStyle(fontSize: 10)),
      ),
    );
    _percents.insert(
      0,
      ButtonSegment<int>(
        value: 0,
        label: Text('0', style: TextStyle(fontSize: 10)),
      ),
    );
    _percents.add(
      ButtonSegment<int>(
        value: 100,
        label: Text('100', style: TextStyle(fontSize: 10)),
      ),
    );

    _volleyType = widget.item[0] as String;
    _percentHopper = widget.item[1] as int;
    _percentAcc = widget.item[2] as int;
    _mainSide = widget.item[3] as int;
    _UIcol = widget.UIcol ?? randPrimary();
  }

  @override
  void didUpdateWidget(covariant VolleyListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item[0] != _volleyType) {
      setState(() {
        _volleyType = widget.item[0] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(widget.item),
      direction: DismissDirection.startToEnd,
      background: CustomContainer(
        color: Colors.red,
        padding: EdgeInsets.only(left: 20, right: 550),
        child: const Icon(Icons.delete_forever_sharp),
      ),
      confirmDismiss:
          (direction) => showDialog(
            context: context,
            builder:
                ((context) => AlertDialog(
                  actionsAlignment: MainAxisAlignment.center,
                  title: Text('Did you want to remove this volley?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Yes'),
                    ),
                  ],
                )),
          ),
      onDismissed: (direction) {
        widget.onDelete();
      },
      child: Card(
        color: widget.color,
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 20, 10),
          child: Row(
            children: [
              Icon(Icons.drag_indicator),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: _volleyType != "harvest",
                      child: Column(
                        children: [
                          const Text('% of Hopper Unloaded'),
                          SegmentedButton<int>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: _UIcol,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              visualDensity: VisualDensity(
                                horizontal: -3,
                                vertical: -3,
                              ),
                            ),
                            segments: _percents,
                            selected: <int>{_percentHopper},
                            onSelectionChanged: (Set<int> newSelection) {
                              setState(() {
                                _percentHopper = newSelection.first;
                                widget.onHopChange(_percentHopper);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _volleyType == "volley",
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          const Text('% of Shots Scored'),
                          SegmentedButton<int>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor: _UIcol,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              visualDensity: VisualDensity(
                                horizontal: -3,
                                vertical: -3,
                              ),
                            ),
                            segments: _percents,
                            selected: <int>{_percentAcc},
                            onSelectionChanged: (Set<int> newSelection) {
                              setState(() {
                                _percentAcc = newSelection.first;
                                widget.onAccChange(_percentAcc);
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        /*const Text('Action:  ', style: TextStyle(height: 0.2, color: Colors.black)),
                        DropdownButton<String>(
                          value: _volleyType,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          elevation: 16,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(height: 2, color: widget.UIcol),
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                _volleyType = value;
                              });
                              widget.onTypeChange(value);
                            }
                          },
                          items: typeList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                        ),
                        SizedBox(width: 20),*/
                        Column(
                          children: [
                            const Text('Robot mainly in this side:'),
                            SegmentedButton<int>(
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                selectedBackgroundColor:
                                    _mainSide == 1
                                        ? Colors.grey[300]
                                        : (_mainSide == 0
                                            ? (widget.isBlue
                                                ? Colors.blue
                                                : Colors.red)
                                            : (widget.isBlue
                                                ? Colors.red
                                                : Colors.blue)),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                visualDensity: VisualDensity(
                                  horizontal: -4,
                                  vertical: -3,
                                ),
                              ),
                              segments: [
                                ButtonSegment(value: 0, label: Text('Home')),
                                ButtonSegment(value: 1, label: Text('Neutral')),
                                ButtonSegment(
                                  value: 2,
                                  label: Text('Opponent'),
                                ),
                              ],
                              selected: <int>{_mainSide},
                              onSelectionChanged: (Set<int> newSelection) {
                                setState(() {
                                  _mainSide = newSelection.first;
                                  widget.onSideChange(_mainSide);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
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

class VolleyWidget extends StatefulWidget {
  final bool isAuto;
  final Color pageColor;
  final Color UIcol;

  const VolleyWidget({
    required this.isAuto,
    required this.pageColor,
    required this.UIcol,
    super.key,
  });
  @override
  State<VolleyWidget> createState() => _VolleyWidgetState();
}

class _VolleyWidgetState extends State<VolleyWidget> {
  late String column;
  late Color buttonCol;
  bool _isBlue = false;
  final cardCol = randPrimary().withAlpha(150);
  late List<dynamic> _items = [];

  // Added ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    column = widget.isAuto ? 'auto_volleys' : 'volleys';
    buttonCol = widget.UIcol;

    // Perform data load and initialization after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndInitializeData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Combines data loading and initialization to ensure order of operations and persistence.
  Future<void> _loadAndInitializeData() async {
    final scoutProvider = Provider.of<ScoutProvider>(context, listen: false);

    // 1. Load existing data
    String data = await scoutProvider.getStringData(column);
    int data2 = await scoutProvider.getIntData('is_blue');

    if (!mounted) return;

    // 2. Process loaded data and update local state
    if (data.isNotEmpty && data != "[]") {
      final decoded = jsonDecode(data);
      // Migration for old data structure
      if (decoded.isNotEmpty &&
          decoded[0] is List &&
          (decoded[0] as List).isNotEmpty &&
          decoded[0][0] is int) {
        _items =
            decoded.map((item) {
              final type = (item[0] == 1) ? 'volley' : 'harvest';
              return [type, item[1], item[2], item[3]];
            }).toList();
      } else {
        _items = decoded;
      }
      setState(() {
        _isBlue = intToBool(data2);
      });
    }

    // 3. Handle auto-initialization ONLY if in auto mode AND no data was loaded.
    // _items will be empty if data == ''
    if (mounted && widget.isAuto && _items.isEmpty) {
      _items.add(['volley', 0, 0, 1]);

      // Update DB. This is safe as it runs after the frame, and the Provider update
      // should trigger the rebuild that draws the new default item.
      scoutProvider.updateData(column, jsonEncode(_items));
      setState(() {});
    }
  }

  void _updateData() {
    Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).updateData(column, jsonEncode(_items));
  }

  // New method to scroll to the bottom of the list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<VolleyListItem> volleys = <VolleyListItem>[
      for (int i = 0; i < _items.length; i += 1)
        VolleyListItem(
          color:
              (_items[i][0] as String) == 'volley'
                  ? cardCol
                  : cardCol.withAlpha(50),
          UIcol: buttonCol,
          isBlue: _isBlue,
          item: _items[i],
          onTypeChange: (String value) {
            setState(() {
              _items[i][0] = value;
            });
            _updateData();
          },
          onHopChange: (int value) {
            _items[i][1] = value;
            _updateData();
          },
          onAccChange: (int value) {
            _items[i][2] = value;
            _updateData();
          },
          onSideChange: (int value) {
            _items[i][3] = value;
            _updateData();
          },
          onDelete: () {
            setState(() {
              _items.removeAt(i);
              _updateData();
            });
          },
          key: ObjectKey(
            _items[i],
          ), // Use ValueKey for better performance/reordering stability
        ),
    ];

    Widget proxyDecorator(
      Widget child,
      int index,
      Animation<double> animation,
    ) {
      return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          final double animValue =
              lerpDouble(0, 1, Curves.easeInOut.transform(animation.value))!;
          final double elevation = lerpDouble(1, 6, animValue)!;
          final double scale = lerpDouble(1, 1.05, animValue)!;
          return Transform.scale(
            scale: scale,
            // Create a Card based on the color and the content of the dragged one
            // and set its elevation to the animated value.
            child: Opacity(
              opacity: 1 - (animation.value * 0.5),
              child: Card(
                elevation: elevation,
                color: volleys[index].color,
                child: volleys[index],
              ),
            ),
          );
        },
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          "Action History",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Expanded(
          flex: 8,
          child: ReorderableListView(
            scrollController: _scrollController, // Attach ScrollController
            padding: const EdgeInsets.symmetric(horizontal: 10),
            proxyDecorator: proxyDecorator,
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final List<dynamic> item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
                _updateData();
              });
            },
            children: volleys,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 50,
              constraints: BoxConstraints(minHeight: 67.7),
              padding: EdgeInsets.only(left: 0, right: 5, top: 10, bottom: 0),
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(buttonCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 35),
                    SizedBox(width: 10),
                    BoldText(text: "Volley", fontSize: 20),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _items.add(['volley', 0, 0, 1]);
                    _updateData();
                  });
                  // Scroll to bottom after adding the item and the UI has rebuilt
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );
                },
              ),
            ),
            Container(
              height: 50,
              constraints: BoxConstraints(minHeight: 67.7),
              padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 0),
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(buttonCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 35),
                    SizedBox(width: 10),
                    BoldText(text: "Pass", fontSize: 20),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _items.add(['pass', 0, 0, 1]);
                    _updateData();
                  });
                  // Scroll to bottom after adding the item and the UI has rebuilt
                  WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(),
                  );
                },
              ),
            ),
            Container(
              height: 50,
              constraints: BoxConstraints(minHeight: 67.7),
              padding: EdgeInsets.only(left: 0, right: 5, top: 10, bottom: 0),
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(buttonCol),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 35),
                    SizedBox(width: 10),
                    BoldText(text: "Harvest", fontSize: 20),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _items.add(['harvest', 0, 0, 1]);
                    _updateData();
                  });
                  // Scroll to bottom after adding the item and the UI has rebuilt
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
