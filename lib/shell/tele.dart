import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


class TeleTab extends StatelessWidget {
  const TeleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randHighlight(), text: 'Tele',),);
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

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      color: randPrimary(), // Setting the background colour
      child: Center(

      ),
    );
  } // Widget build
} // _TelePageState