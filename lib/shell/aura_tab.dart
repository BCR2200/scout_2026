import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';

class AuraTab extends StatefulWidget {

  const AuraTab({ super.key});
  @override
  State<AuraTab> createState() => _AuraTabState();

}

class _AuraTabState extends State<AuraTab> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ColorProvider(),
        builder: (context, child) {return Tab(child: ColouredTab(color: Color(ColorProvider().auraCol), text: 'Aura'));});
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
  late Color pageColor;
  late Color UIcol;
  // Building the widget tree

  @override
  void initState() {
    super.initState();
    pageColor = randPrimary();
    UIcol = randHighlight();

    ColorProvider().updateColor('auraCol', pageColor);
    ColorProvider().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: ClimbWidget(isAuto: true, pageColor: UIcol,),
          ),
          Expanded(
            flex: 3,
            child: CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(50, 0, 50, 50),
              padding: EdgeInsets.all(25),
              child: VolleyWidget(isAuto: true, pageColor: pageColor, UIcol: UIcol,),
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
