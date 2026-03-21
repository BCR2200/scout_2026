import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescout_2026/shell/shell_library.dart';
import 'package:rescout_2026/databasing/provider_service.dart';

class TeleTab extends StatelessWidget {
  const TeleTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes to teleCol and rebuild the Tab
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        return Tab(
          child: ColouredTab(
            color: Color(colorProvider.teleCol),
            text: 'Teleop',
          ),
        );
      },
    );
  }
}

// TelePage is a stateful widget called when creating the Tele code page.
class TelePage extends StatefulWidget {
  final VoidCallback? callback;

  const TelePage({super.key, this.callback}); // Constructor
  @override
  State<TelePage> createState() => _TelePageState();
}

class _TelePageState extends State<TelePage> {
  late Color initialPageColor;
  late Color UIcol1, UIcol2, UIcol3, UIcol4;

  @override
  void initState() {
    super.initState();


    // Defer color update until after build to avoid assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      initialPageColor = randPrimary(
        exclude: [
          Color(colorProvider.auraCol),
          Color(colorProvider.endCol),
          Color(colorProvider.qrCol),
        ],
      );
      colorProvider.updateColor('teleCol', initialPageColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates reactively
    final colorProvider = Provider.of<ColorProvider>(context);
    final pageColor = Color(colorProvider.teleCol);
    if (colorProvider.isRandom) {
      UIcol1 = randHighlight();
      UIcol2 = randHighlight(exclude: [UIcol1]);
      UIcol3 = randHighlight(exclude: [UIcol1, UIcol2]);
      UIcol4 = randHighlight(exclude: [UIcol1, UIcol2, UIcol3]);
    } else {
      UIcol1 = Colors.red;
      UIcol2 = Colors.yellow;
      UIcol3 = Colors.deepPurple;
      UIcol4 = Colors.blue;
    }

    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TimerButton(
                    margin: EdgeInsets.fromLTRB(25, 25, 12.5, 12.5),
                    color: UIcol1,
                    text: 'Shoot',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                    column: 'shoot_timer',
                  ),
                ),
                Expanded(
                  child: TimerButton(
                    margin: EdgeInsets.fromLTRB(12.5, 25, 25, 12.5),
                    color: UIcol2,
                    text: 'Intake',
                    style: TextStyle(
                      fontSize: 30,
                      ),
                    column: 'intake_timer',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: TimerButton(
                    margin: EdgeInsets.fromLTRB(25, 12.5, 12.5, 20),
                    color: UIcol3,
                    text: 'Pass',
                    style: TextStyle(
                      fontSize: 30,
                      ),
                    column: 'pass_timer',
                  ),
                ),
                Expanded(
                  child: TimerButton(
                    margin: EdgeInsets.fromLTRB(12.5, 12.5, 25, 20),
                    color: UIcol4,
                    text: 'Defend',
                    style: TextStyle(
                      fontSize: 30,
                      ),
                    column: 'defence_timer',
                  ),
                ),
              ],
            ),
          ),
          UndoWidget(margin: EdgeInsets.fromLTRB(25, 0, 25, 10)),
          NumberInputWidget(
            column: 'fouls', // Setting the column for the database
            scale: 1.25,
            title: 'Fouls',
            fontSize: 30.0,
          ),
          SizedBox(height:25),
          CustomContainer(
            margin: EdgeInsets.only(left: 25, right: 25, bottom: 10),
            color: Colors.white,
            padding: EdgeInsets.all(10),

            child: Consumer<TimerStateProvider>(
                builder: (context, timerProvider, child) { return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TimerButton(
                    color: pageColor, text: 'Dead', column: 'dead_timer', isToggle: timerProvider.isToggle,
                  ),
                ),
                Expanded(
                  child: TimerButton(
                    color: pageColor, text: 'Beached', column: 'beached_timer', isToggle: timerProvider.isToggle,
                  ),
                ),
                Expanded(
                  child: TimerButton(
                    color: pageColor, text: 'Inoperable', column: 'inop_timer', isToggle: timerProvider.isToggle,
                  ),
                ),
              ],
            );
                }
                ),

          ),
        ],
      ),
    );
  } // Widget build
} // _TelePageState
