import 'package:flutter/material.dart';
import 'package:scout_shell/shell/shell_library.dart';


class TeleTab extends StatelessWidget {
  const TeleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Tab(child: ColouredTab(color: randHighlight(), text: 'Teleop',),);
  }
}


// TelePage contains the teleop period data collection
class TelePage extends StatefulWidget {
  final VoidCallback? callback;

  const TelePage({super.key, this.callback});
  @override
  State<TelePage> createState() => _TelePageState();
}

class _TelePageState extends State<TelePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: randPrimary(),
      child: Column(
        children: [
          // Climb widget for teleop/endgame
          ClimbWidget(
            title: 'Teleop/Endgame Climb',
            levelColumn: 'teleop_climb_level',
            positionColumn: 'teleop_climb_position',
          ),

          const Divider(color: Colors.white38, thickness: 1),

          // Volleys section
          Expanded(
            child: VolleyListWidget(
              column: 'teleop_volleys',
              title: 'Teleop Volleys',
            ),
          ),
        ],
      ),
    );
  }
}
