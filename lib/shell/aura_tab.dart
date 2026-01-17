import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


class AuraTab extends StatelessWidget {
  const AuraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randHighlight(), text: 'Aura',),);
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
  int _climbLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadClimbLevel();
  }

  Future<void> _loadClimbLevel() async {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      int level = await provider.getIntData('climb_level');
      setState(() {
        _climbLevel = level;
      });
    }
  }

  void _updateClimbLevel(int? value) {
    if (value != null) {
      setState(() {
        _climbLevel = value;
      });
      final provider = Provider.of<ScoutProvider>(context, listen: false);
      if (provider.currentMatch.isNotEmpty) {
        provider.updateData('climb_level', value);
      }
    }
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      color: randPrimary(), // Setting the background colour
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Climb Level',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            RadioListTile<int>(
              title: const Text('None', style: TextStyle(color: Colors.white)),
              value: 0,
              groupValue: _climbLevel,
              onChanged: _updateClimbLevel,
              activeColor: Colors.white,
            ),
            RadioListTile<int>(
              title: const Text('Level 1', style: TextStyle(color: Colors.white)),
              value: 1,
              groupValue: _climbLevel,
              onChanged: _updateClimbLevel,
              activeColor: Colors.white,
            ),
            RadioListTile<int>(
              title: const Text('Level 2', style: TextStyle(color: Colors.white)),
              value: 2,
              groupValue: _climbLevel,
              onChanged: _updateClimbLevel,
              activeColor: Colors.white,
            ),
            RadioListTile<int>(
              title: const Text('Level 3', style: TextStyle(color: Colors.white)),
              value: 3,
              groupValue: _climbLevel,
              onChanged: _updateClimbLevel,
              activeColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  } // Widget build
} // _AuraPageState