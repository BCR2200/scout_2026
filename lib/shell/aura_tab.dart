import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';

class AuraTab extends StatelessWidget {

  const AuraTab({ super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes to auraCol and rebuild the Tab
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        return Tab(
          child: ColouredTab(
            color: Color(colorProvider.auraCol), 
            text: 'Aura'
          )
        );
      },
    );
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
  // We no longer need pageColor as state, but we need to generate it once
  late Color initialPageColor;
  final Color initialUIcol = randHighlight();
  
  @override
  void initState() {
    super.initState();
    
    // Defer color update until after build to avoid assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      initialPageColor = randPrimary(exclude: [
        Color(colorProvider.teleCol),
        Color(colorProvider.endCol),
        Color(colorProvider.qrCol),
      ]);
      colorProvider.updateColor('auraCol', initialPageColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates when provider changes (e.g., when loading settings)
    final colorProvider = Provider.of<ColorProvider>(context);
    final pageColor = Color(colorProvider.auraCol);
    
    // UIcol is based on the initial page color, so we use the stored initial value.
    // If UIcol is used as an accent, it should be derived from the current page color.
    // Assuming UIcol is an accent color and should only be generated once per session:
    final UIcol = initialUIcol;

    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          ClimbWidget(isAuto: true, pageColor: UIcol),
          Expanded(
            child: CustomContainer(
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(25, 0, 25, 25),
              padding: EdgeInsets.all(15),
              child: VolleyWidget(isAuto: true, pageColor: pageColor, UIcol: UIcol),
            ),
          ),
        ],
      ),
    );
  }
}
