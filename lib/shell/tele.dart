import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:tele_flutter/tele_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';

class TeleTab extends StatelessWidget {

  const TeleTab({ super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randPrimary(), text: 'Tele'));
  }
}

// TelePage is a stateless widget called when creating the Tele code page.
class TelePage extends StatefulWidget {
  final VoidCallback? callback;

  const TelePage({super.key, this.callback}); // Constructor
  @override
  State<TelePage> createState() => _TelePageState();
}

class _TelePageState extends State<TelePage> {
  late Color pageColor;
  // Building the widget tree

  @override
  void initState() {
    super.initState();
    pageColor = randPrimary();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
              padding: EdgeInsets.all(25),
              child: VolleyWidget(isAuto: false, pageColor: pageColor, UIcol: randHighlight(),),
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
} // _TelePageState
