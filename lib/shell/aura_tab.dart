import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rescout_2026/shell/shell_library.dart';
import 'package:rescout_2026/databasing/provider_service.dart';

class AuraTab extends StatelessWidget {
  const AuraTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes to auraCol and rebuild the Tab
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        return Tab(
          child: ColouredTab(color: Color(colorProvider.auraCol), text: 'Auto'),
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

  String _startSide = 'Hub';
  Set<String> _intakeSpots = {};

  @override
  void initState() {
    super.initState();

    // Defer color update until after build to avoid assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      initialPageColor = randPrimary(
        exclude: [
          Color(colorProvider.teleCol),
          Color(colorProvider.endCol),
          Color(colorProvider.qrCol),
        ],
      );
      colorProvider.updateColor('auraCol', initialPageColor);
      _loadData();
    });
  }

  Future<void> _loadData() async {
    String sideData = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getStringData('start_side');

    String intakeData = await Provider.of<ScoutProvider>(
      context,
      listen: false,
    ).getStringData('intake_spots');

    // If the widget is still active and the data isn't the default value (a space)
    if (mounted && sideData.isNotEmpty) {
      setState(() {
        _startSide = sideData;
      });
    }

    if (mounted && intakeData.isNotEmpty) {
      setState(() {
        _intakeSpots = Set<String>.from(jsonDecode(intakeData));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates when provider changes (e.g., when loading settings)
    final colorProvider = Provider.of<ColorProvider>(context);
    final pageColor = Color(colorProvider.auraCol);
    late Color UIcol;

    if (colorProvider.isRandom) {
      UIcol = initialUIcol;
    }  else UIcol = Colors.lightGreen;

    // UIcol is based on the initial page color, so we use the stored initial value.
    // If UIcol is used as an accent, it should be derived from the current page color.
    // Assuming UIcol is an accent color and should only be generated once per session:

    return Container(
      color: pageColor, // Setting the background colour
      child: Column(
        children: [
          CustomContainer(
            color: Colors.white,
            margin: EdgeInsets.fromLTRB(25, 25, 25, 0),
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                BoldText(
                  text: "Start Position (Driver Perspective):",
                  fontSize: 20,
                ),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: UIcol,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: 'Left Trench',
                      label: Text('L Trench'),
                    ),
                    ButtonSegment<String>(
                      value: 'Left Bump',
                      label: Text('L Bump'),
                    ),
                    ButtonSegment<String>(value: 'Hub', label: Text('Hub')),
                    ButtonSegment<String>(
                      value: 'Right Bump',
                      label: Text('R Bump'),
                    ),
                    ButtonSegment<String>(
                      value: 'Right Trench',
                      label: Text('R Trench'),
                    ),
                  ],
                  selected: <String>{_startSide},
                  onSelectionChanged: (Set<String> newSelection) {
                    if (_startSide != '') {
                      setState(() {
                        _startSide = newSelection.first;
                        Provider.of<ScoutProvider>(
                          context,
                          listen: false,
                        ).updateData('start_side', _startSide);
                      });
                    }
                  },
                ),

                Divider(color: Colors.grey, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        BoldText(text: "Intake Spots:", fontSize: 20),
                        SegmentedButton<String>(
                          emptySelectionAllowed: true,
                          multiSelectionEnabled: true,
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: UIcol,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          segments: const <ButtonSegment<String>>[
                            ButtonSegment<String>(
                              value: 'depot',
                              label: Text('Depot'),
                            ),
                            ButtonSegment<String>(
                              value: 'neutral',
                              label: Text('Neutral'),
                            ),
                            ButtonSegment<String>(
                              value: 'outpost',
                              label: Text('Outpost'),
                            ),
                          ],
                          selected: _intakeSpots,
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _intakeSpots = newSelection;
                              Provider.of<ScoutProvider>(
                                context,
                                listen: false,
                              ).updateData(
                                'intake_spots',
                                jsonEncode(_intakeSpots.toList()),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    VerticalDivider(
                      width: 40,
                      color: Colors.grey,
                      thickness: 1.5,
                    ),
                    Text('Fired Preload?', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    CustomCheckBox(column: "preload", checkColor: UIcol),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TimerButton(
              margin: EdgeInsets.only(left:50, top: 50, right:50, bottom: 20),
              color: UIcol,
              text: 'Shoot',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Red_Hat_Display'),
              column: 'auto_timer',
            ),
          ),
          UndoWidget(margin: EdgeInsets.fromLTRB(50, 0, 50, 25)),
          ClimbWidget(isAuto: true, pageColor: UIcol),
        ],
      ),
    );
  }
}
