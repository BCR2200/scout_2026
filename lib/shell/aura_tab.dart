import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


class AuraTab extends StatelessWidget {
  const AuraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randHighlight(), text: 'Aura',),);
  }
}


// AuraPage is a stateful widget for the auto period data collection
class AuraPage extends StatefulWidget {
  final VoidCallback? callback;

  const AuraPage({super.key, this.callback});
  @override
  State<AuraPage> createState() => _AuraPageState();
}

class _AuraPageState extends State<AuraPage> {
  int _startPosition = 0; // 0 = not set, 1-6 for positions
  bool _autoMoved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      int startPos = await provider.getIntData('start_position');
      int moved = await provider.getIntData('auto_moved');

      if (mounted) {
        setState(() {
          _startPosition = startPos;
          _autoMoved = moved == 1;
        });
      }
    }
  }

  void _updateStartPosition(int value) {
    setState(() {
      _startPosition = value;
    });
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      provider.updateData('start_position', value);
    }
  }

  void _updateAutoMoved(bool value) {
    setState(() {
      _autoMoved = value;
    });
    final provider = Provider.of<ScoutProvider>(context, listen: false);
    if (provider.currentMatch.isNotEmpty) {
      provider.updateData('auto_moved', value ? 1 : 0);
    }
  }

  Widget _buildStartPositionButton(int position, String label) {
    final isSelected = _startPosition == position;
    return GestureDetector(
      onTap: () => _updateStartPosition(position),
      child: Container(
        width: 80,
        height: 50,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white38,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.blue[800] : Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: randPrimary(),
      child: Column(
        children: [
          // Starting position section
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const BoldText(
                  text: 'Starting Position',
                  fontSize: 20,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStartPositionButton(1, 'Pos 1'),
                    _buildStartPositionButton(2, 'Pos 2'),
                    _buildStartPositionButton(3, 'Pos 3'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStartPositionButton(4, 'Pos 4'),
                    _buildStartPositionButton(5, 'Pos 5'),
                    _buildStartPositionButton(6, 'Pos 6'),
                  ],
                ),
              ],
            ),
          ),

          // Robot moved checkbox
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BoldText(
                  text: 'Robot Moved in Auto:',
                  fontSize: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: _autoMoved,
                    onChanged: (value) => _updateAutoMoved(value ?? false),
                    activeColor: Colors.white,
                    checkColor: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white38, thickness: 1),

          // Climb widget
          ClimbWidget(
            title: 'Auto Climb',
            levelColumn: 'auto_climb_level',
            positionColumn: 'auto_climb_position',
          ),

          const Divider(color: Colors.white38, thickness: 1),

          // Volleys section
          Expanded(
            child: VolleyListWidget(
              column: 'auto_volleys',
              title: 'Auto Volleys',
            ),
          ),
        ],
      ),
    );
  }
}
