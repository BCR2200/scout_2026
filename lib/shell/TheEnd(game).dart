import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:aura_flutter/aura_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


class TheEndTab extends StatelessWidget {
  const TheEndTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randHighlight(), text: 'THE END',),);
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
  int _climbStatus = 0; // 0: None, 1: 1L, 2: 1M, 3: 1R, 4: 2L, 5: 2M, 6: 2R, 7: 3L, 8: 3M, 9: 3R

  @override
  void initState() {
    super.initState();
    _loadClimbData();
  }

  Future<void> _loadClimbData() async {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      int level = await provider.getIntData('climb_level');
      int position = await provider.getIntData('climb_position');

      setState(() {
        if (level == 0) {
          _climbStatus = 0;
        } else {
          // Mapping: Status = (level - 1) * 3 + position
          _climbStatus = (level - 1) * 3 + position;
        }
      });
    }
  }

  void _updateClimbStatus(int? value) {
    if (value != null) {
      setState(() {
        _climbStatus = value;
      });

      int level = 0;
      int position = 0;

      if (value > 0) {
        level = ((value - 1) ~/ 3) + 1;
        position = ((value - 1) % 3) + 1;
      }

      final provider = Provider.of<ScoutProvider>(context, listen: false);
      if (provider.currentMatch.isNotEmpty) {
        provider.updateData('climb_level', level);
        provider.updateData('climb_position', position);
      }
    }
  }

  Widget _buildRadioOption(String label, int value) {
    return InkWell(
      onTap: () => _updateClimbStatus(value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<int>(
            value: value,
            groupValue: _climbStatus,
            onChanged: _updateClimbStatus,
            activeColor: Colors.white,
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Building the widget tree
  @override
  Widget build(BuildContext context) {
    return Container(
      color: randPrimary(), // Setting the background colour
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Climb Status',
                  style: TextStyle(fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                Table(
                  children: [
                    TableRow(
                      children: [
                        _buildRadioOption('3L', 7),
                        _buildRadioOption('3M', 8),
                        _buildRadioOption('3R', 9),
                      ],
                    ),
                    const TableRow(children: [
                      SizedBox(height: 15),
                      SizedBox(height: 15),
                      SizedBox(height: 15)
                    ]),
                    TableRow(
                      children: [
                        _buildRadioOption('2L', 4),
                        _buildRadioOption('2M', 5),
                        _buildRadioOption('2R', 6),
                      ],
                    ),
                    const TableRow(children: [
                      SizedBox(height: 15),
                      SizedBox(height: 15),
                      SizedBox(height: 15)
                    ]),
                    TableRow(
                      children: [
                        _buildRadioOption('1L', 1),
                        _buildRadioOption('1M', 2),
                        _buildRadioOption('1R', 3),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildRadioOption('None', 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}