import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescout_2026/shell/shell_library.dart';
import 'package:rescout_2026/databasing/provider_service.dart';

class TeleTab extends StatelessWidget {

  const TeleTab({ super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes to teleCol and rebuild the Tab
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        return Tab(
          child: ColouredTab(
            color: Color(colorProvider.teleCol), 
            text: 'Teleop'
          )
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
  late Color initialUIcol;

  @override
  void initState() {
    super.initState();
    initialUIcol = randHighlight();

    // Defer color update until after build to avoid assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      initialPageColor = randPrimary(exclude: [
        Color(colorProvider.auraCol),
        Color(colorProvider.endCol),
        Color(colorProvider.qrCol),
      ]);
      colorProvider.updateColor('teleCol', initialPageColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates reactively
    final colorProvider = Provider.of<ColorProvider>(context);
    final pageColor = Color(colorProvider.teleCol);
    final UIcol = initialUIcol; // Assuming UIcol uses the initial accent color

    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(25, 25, 25, 25),
              padding: EdgeInsets.all(25),
              child: VolleyWidget(isAuto: false, pageColor: pageColor, UIcol: UIcol),
            ),
          ),
        ],
      ),
    );
  } // Widget build
} // _TelePageState
