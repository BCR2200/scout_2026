import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'package:theEnd_flutter/theEnd_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';

class TheEndTab extends StatefulWidget {

  const TheEndTab({ super.key});
  @override
  State<TheEndTab> createState() => _TheEndTabState();

}

class _TheEndTabState extends State<TheEndTab> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: ColorProvider(),
        builder: (context, child) {return Tab(child: ColouredTab(color: Color(ColorProvider().endCol), text: 'post mortem'));});
  }
}

// TheEndPage is a stateless widget called when creating the TheEnd code page.
class TheEndPage extends StatefulWidget {
  final VoidCallback? callback;

  const TheEndPage({super.key, this.callback}); // Constructor
  @override
  State<TheEndPage> createState() => _TheEndPageState();
}

class _TheEndPageState extends State<TheEndPage> {
  late Color pageColor;
  // Building the widget tree

  @override
  void initState() {
    super.initState();
    pageColor = randPrimary();

    ColorProvider().updateColor('endcol', pageColor);
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
            child: ClimbWidget(isAuto: false, pageColor: pageColor,),
          ),
          Expanded(
            flex: 1,
            child: NotesWidget()
          ),
          Expanded(
            flex: 1,
            child: DriverSlider()
          ),
          Expanded(
            flex: 1,
            child: DefenceSlider()
          ),
      ],
    ),
    );
  } // Widget build
} // _TheEndPageState
