import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


class TheEndTab extends StatelessWidget {
  const TheEndTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: Colors.amber[800]!, text: 'THE END',),);
  }
}



// TheEndPage is a stateless widget called when creating the Tele code page.
class TheEndPage extends StatefulWidget {
  final VoidCallback? callback;

  const TheEndPage({super.key, this.callback}); // Constructor
  @override
  State<TheEndPage> createState() => _TheEndPageState();
}
class _TheEndPageState extends State<TheEndPage> {

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber[800]!, // Setting the background colour
      child: Center(

      ),
    );
  } // Widget build
} // _TheEndPageState