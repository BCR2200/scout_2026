import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';

class TheEndTab extends StatelessWidget {

  const TheEndTab({ super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes to endCol and rebuild the Tab
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        return Tab(
          child: ColouredTab(
            color: Color(colorProvider.endCol),
            text: 'post mortem'
          )
        );
      },
    );
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
  // Use a nullable Color here, but it will be guaranteed to be initialized before use in build via load.
  late Color initialPageColor;

  @override
  void initState() {
    super.initState();
    
    // Defer color update until after build to avoid assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      initialPageColor = randPrimary(exclude: [
        Color(colorProvider.auraCol),
        Color(colorProvider.teleCol),
        Color(colorProvider.qrCol),
      ]);
      // Corrected column key to 'endCol'
      Provider.of<ColorProvider>(context, listen: false).updateColor('endCol', initialPageColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates reactively
    final colorProvider = Provider.of<ColorProvider>(context);
    final pageColor = Color(colorProvider.endCol);

    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          WhoScoutedWidget(),
          ClimbWidget(isAuto: false, pageColor: pageColor,),
          CustomContainer(
            color: Colors.white,
            margin: EdgeInsets.only(left: 25, right: 25, bottom: 25),
            padding: EdgeInsets.all(15),
            child: NotesWidget(),
          ),
          RobotDied(column: 'robot died',),
          const Expanded(
            flex: 1,
            child: DriverSlider()
          ),
          const Expanded(
            flex: 1,
            child: Intakerating()
          ),
          const Expanded(
            flex: 1,
            child: MainRoleSlider()
          ),
          const Expanded(
            flex: 1,
            child: OffenceSlider(),
          ),
      ],
    ),
    );
  } // Widget build
} // _TheEndPageState
