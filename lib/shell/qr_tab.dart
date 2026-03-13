import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rescout_2026/shell/shell_library.dart';
import 'package:rescout_2026/databasing/provider_service.dart';

class QrTab extends StatelessWidget {
  const QrTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen for changes to qrCol and rebuild the Tab
    return Consumer<ColorProvider>(
      builder: (context, colorProvider, child) {
        return Tab(
          child: ColouredTab(
            color: Color(colorProvider.qrCol), 
            text: 'QR'
          ),
        );
      },
    );
  }
}

// QRPage is a stateful widget called when creating the QR code page.
class QRPage extends StatefulWidget {
  final VoidCallback? callback;
  
  const QRPage({super.key, this.callback}); // Constructor
  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  // Use a final variable to store the initial random color
  late final Color initialColor;

  @override
  void initState() {
    super.initState();

    // Defer color update until after build to avoid assertion error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final colorProvider = Provider.of<ColorProvider>(context, listen: false);
      initialColor = randPrimary(exclude: [
        Color(colorProvider.auraCol),
        Color(colorProvider.teleCol),
        Color(colorProvider.endCol),
      ]);
      Provider.of<ColorProvider>(context, listen: false).updateColor('qrCol', initialColor);
    });
  }

  Future<Map<String, dynamic>> _fetchRequirementsAndQR(ScoutProvider provider) async {
    String matchReq = provider.currentMatch;
    int teamNum = provider.teamNum;
    
    // Actually grab it straight from the DB instead of relying on local cached state
    String whoScouted = '';
    if (matchReq.trim().isNotEmpty) {
      try {
        whoScouted = await provider.getStringData('who_scouted');
      } catch (e) {
        whoScouted = '';
      }
    }

    bool teamReq = teamNum != 0;
    bool scouterReq = whoScouted.trim().isNotEmpty;
    bool matchValid = matchReq.trim().isNotEmpty;

    bool hasReq = teamReq && scouterReq && matchValid;
    String noReqText = 'all requirements met';

    if (!teamReq) {
      noReqText = 'No team number';
    } else if (!scouterReq) {
      noReqText = 'No scouter name/match name';
    } else if (!matchValid) {
      noReqText = 'No match name';
    }

    List<String>? qrData;
    if (hasReq) {
      qrData = await provider.getQRData();
    }

    return {
      'hasReq': hasReq,
      'noReqText': noReqText,
      'qrData': qrData,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates reactively
    final colorProvider = Provider.of<ColorProvider>(context);
    final primaryColor = Color(colorProvider.qrCol);

    return Container(
      color: primaryColor, // Setting the background colour
      child: Center(
        // The Consumer ensures that whenever you update ANY info (like typing a scouter name)
        // the QR tab rebuilds and recalculates if requirements are met immediately!
        child: Consumer<ScoutProvider>(
          builder: (context, provider, child) {
            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchRequirementsAndQR(provider),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final data = snapshot.data;
                if (data == null) {
                  return const CircularProgressIndicator();
                }

                bool hasReq = data['hasReq'];
                String noReqText = data['noReqText'];
                List<String>? qrData = data['qrData'];

                if (hasReq && qrData != null) {
                  return Container(
                    margin: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 150),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        QrImageView(
                          data: qrData.join("\t").toString(),
                          version: QrVersions.auto,
                          size: 450,
                          backgroundColor: Colors.white,
                        ),
                        NextMatchWidget(callback: widget.callback, color: primaryColor,)
                      ],
                    ),
                  );
                } else {
                  return CustomContainer(
                    color: Colors.red,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      '$noReqText',
                      style: const TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                    )
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
