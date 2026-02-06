import 'package:flutter/material.dart';
import 'package:scout_shell/shell/TheEnd(game).dart';
import 'package:scout_shell/shell/aura_tab.dart';
import 'package:scout_shell/shell/shell_library.dart';
import 'package:scout_shell/shell/tele.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scout_shell/shell/app_layout.dart';
import 'package:scout_shell/shell/qr_tab.dart';

// The main function is the entry point of the application.
void main() async {
  // Removed unused local color variables

  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialized so the SharedPreferences doesn't cause a bug
  SharedPreferences prefs =
      await SharedPreferences.getInstance(); // Getting an instance of the SharedPreferences (basic save data)
  bool scoutIndexChosen =
      prefs.getBool('scoutIndexChosen') ??
      false; // see if index is chosen, false if it doesn't exist

  runApp(
    ScoutApp(
      scoutIndexChosen: scoutIndexChosen,

      /* =================================*
     *             ATTENTION            *
     * =================================*
     *
     * This is the location where you add all of your tab/page widgets
     * The QR page + tab has already been created for you
     *
     * From here you can make your own files to create your own pages/tabs or just make them here.
     * I recommend you check out the example in the explained_example.dart file to see how to generally make one
     *
     * Once you finish a tab/page just put it in its respective list
    **/
      tabs: [AuraTab(), TeleTab(), TheEndTab(), QrTab()],
      pages: [
        AuraPage(
        ),
        TelePage(),
        TheEndPage(),
        // QRPage(),  - now is part of app_layout in order to make "next match" go to the first tab
      ],
    ),
  ); // Runs the app
}
