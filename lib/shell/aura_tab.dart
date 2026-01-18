import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';

class AuraTab extends StatelessWidget {
  const AuraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randPrimary(), text: 'Aura'));
  }
}

// AuraPage is a stateless widget called when creating the Aura code page.
class AuraPage extends StatefulWidget {
  final VoidCallback? callback;

  const AuraPage({super.key, this.callback}); // Constructor
  @override
  State<AuraPage> createState() => _AuraPageState();
}

class _AuraPageState extends State<AuraPage> {
  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      color: randPrimary(), // Setting the background colour
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: CustomContainer(
              color: Colors.white,
              padding: const EdgeInsets.all(50),
              margin: EdgeInsets.all(50),
              child: Row(
                children: [
                  BoldText(text: "Climb Status"),
                  Expanded(
                    //flex: 1,
                    child: TestSlider(
                      divisions: 2,
                      minVal: 1.0,
                      maxVal: 3.0,
                      title: 'Climb Level',
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*Expanded(
            flex: 4,
            child: CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.all(50),
              padding: EdgeInsets.all(50),
            ),
          ),*/
        ],
      ),
    );
  } // Widget build
} // _AuraPageState
