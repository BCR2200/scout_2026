import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


class AuraTab extends StatelessWidget {
  const AuraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: Colors.orange[800]!, text: 'Aura',),);
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
      color: Colors.orange[800]!, // Setting the background colour
      child: Center(

      ),
    );
  } // Widget build
} // _AuraPageState