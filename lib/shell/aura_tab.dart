import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              padding: const EdgeInsets.fromLTRB(50, 25, 25, 25),
              margin: EdgeInsets.all(50),
              child: Row(
                children: [
                  BoldText(text: "Climb\nStatus", fontSize: 30,),

                  //flex: 1,
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: TestSlider(
                            activeColor: randPrimary(),
                            useNumbers: false,
                            divisions: 3,
                            minVal: 0.0,
                            maxVal: 3.0,
                            title: 'Climb Level',
                            labels: ['No Climb', 'L1', 'L2', 'L3'],
                          ),
                        ),
                        Container(height: 10,),
                        Text("Climb Side"),
                        Expanded(
                          //flex: 1,
                          child: ClimbPosSelect(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
              padding: EdgeInsets.all(50),
              /*child: Column(
                children:[
                  Expanded(
                    child: ReorderableListView(children: children, onReorder: onReorder)
                  ),
                  Row(
                    children: [
                      BoldText(text: "Shift Change"),

                      BoldText(text: "Volleys")
                    ]
                  )
                ]
              )*/
            ),
          ),
        ],
      ),
    );
  } // Widget build
} // _AuraPageState
