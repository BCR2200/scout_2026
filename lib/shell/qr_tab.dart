import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/databasing/provider_service.dart';


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
  
  @override
  Widget build(BuildContext context) {
    // Read color from provider to ensure page color updates reactively
    final colorProvider = Provider.of<ColorProvider>(context);
    final primaryColor = Color(colorProvider.qrCol);

    return Container(
      color: primaryColor, // Setting the background colour
      child: Center(
        child: FutureBuilder<List<String>>(
          // Getting QR data from the database, which uses a FutureBuilder because it is asynchronous
          future: Provider.of<ScoutProvider>(context).getQRData(),
          builder: (context, AsyncSnapshot<List<String>> snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Loading widget
            } else if (snapShot.hasError) {
              return Text('Error: ${snapShot.error}'); // Error widget
            } else if (snapShot.hasData) {
              // If it got the QRData, show the QR code
              return Container(
                margin: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 150), // Outer spacing
                padding: const EdgeInsets.all(10.0), // Inner spacing
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0), // Rounding the corners
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Align to squish into the center
                  children: [
                    QrImageView(
                      // The QR data is joined with tab to make it tab between each entry in the QR code 
                      data: snapShot.data!.join("\t").toString(),
                      version: QrVersions.auto,
                      size: 500, // QR code size
                      backgroundColor: Colors.white,
                    ),
                    NextMatchWidget(callback: widget.callback, color: primaryColor,) // Button to move on to the next match
                  ], // children:
                ),
              );
            } else {
              return const Text('No data to generate QR code.'); // Empty data widget
            }
          }, // builder:
        ),
      ),
    );
  } // Widget build
} // _QRPageState
