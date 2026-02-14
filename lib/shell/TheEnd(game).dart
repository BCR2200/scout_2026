import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescout_2026/shell/shell_library.dart';
import 'package:rescout_2026/databasing/provider_service.dart';

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
    final UIcol = randHighlight();

    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          WhoScoutedWidget(UIcol: UIcol, margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25), ),
          ClimbWidget(isAuto: false, pageColor: UIcol, margin: EdgeInsets.only(left: 25, right: 25, bottom: 10), ),
            CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.only(left: 25, right: 25, bottom: 10),
              padding: EdgeInsets.all(15),
              child: NotesWidget(UIcol: UIcol,),
            ),
          CustomContainer(
              margin: EdgeInsets.only(left: 25, right: 25, bottom: 10),
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RobotDied(
                    title: "Robot Died",
                    column: 'died',
                    scale: 1.5,
                    fontSize: 20,
                    checkColor: randPrimary(),
                  ),
                  Beached(
                    title: "Robot Beached",
                    column: 'beached',
                    scale: 1.5,
                    fontSize: 20,
                    checkColor: randPrimary(),
                  ),
                  FuelJammed(
                    title: "Fuel Jammed",
                    column: 'jammed',
                    scale: 1.5,
                    fontSize: 20,
                    checkColor: randPrimary(),
                  ),
                ],
              ),
            ),
          Expanded(
            child: CustomContainer(
              margin: EdgeInsets.only(left: 25, right: 25, bottom: 10),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DriverSlider(),
                  //IntakeRating(),
                  MainRoleSlider(),
                  OffenceSlider(),
                ],
              ),
            ),
          ),
      ],
    ),
    );
  } // Widget build
} // _TheEndPageState
