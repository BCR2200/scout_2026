import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:rescout_2026/shell/shell_library.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scout_data.dart';

// ScoutProvider is a state management system and is the gateway to the database
// This is so a change far down the "widget tree" can update something higher up, like
// if you change the match is will update the page to display the contents of that match
class ScoutProvider extends ChangeNotifier {
  // The list scoutItem holds every match as a ScoutModel
  // This is primarily used for the match catalog to select and display matches
  List<ScoutModel> scoutItem = [];

  // Set a private and public currentMatch
  String _currentMatch = '';
  String get currentMatch => _currentMatch;

  String _nextUntitled = '';
  String get nextUntitled => _nextUntitled;

  // Set a private and public teamNum
  int _teamNum = 0;
  int get teamNum => _teamNum;

  String _currentScouter = '';
  String get currentScouter => _currentScouter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ScoutProvider() {
    _initMatch();
  }

  Future<void> _initMatch() async {
    if (_currentMatch.trim().isEmpty) {
      await insertMatch('');
    }
  }

  // Display all matches that contain the input search
  Future<void> searchData(String search) async {
    _isLoading = true;
    notifyListeners();

    final dataList =
        await ScoutDatabase.selectSpecific(ScoutDatabase.tableName, search);

    // TODO UPDATE

    /* =================================*
     *             ATTENTION            *
     * =================================*
     *  
     * This is the location you'll have to manually change some stuff 
     * If you see below, it will show ___: e['___'] as ____
     * Just simply follow the same logical flow as the elements already there
     * but with the elements you want to add, and it should work just fine
     * 
    **/

    // Inputting all the data from the database into the scoutItem list
    scoutItem = dataList
        .map(
          (e) => ScoutModel(
            team: e['team'] as int,
            match_name: e['match_name'] as String,
            defence: e['defence'] as int,
            drive_rating: e['drive_rating'] as int,
            fouls: e['fouls'] as int,
            auto_climb_level: e['auto_climb_level'] as int,
            auto_climb_position: e['auto_climb_position'] as int,
            climb_level: e['climb_level'] as int,
            climb_position: e['climb_position'] as int,
            notes: e['notes'] as String,
            main_role: e['main_role'] as String,
            who_scouted: e['who_scouted'] as String,
            auto_timer: e['auto_timer'] as String,
            shoot_timer: e['shoot_timer'] as String,
            intake_timer: e['intake_timer'] as String,
            pass_timer: e['pass_timer'] as String,
            defence_timer: e['defence_timer'] as String,
            preload: e['preload'] as int,
            intake_spots: e['intake_spots'] as String,
            start_side: e['start_side'] as String,
            accuracy: e['accuracy'] as int,
            vibes: e['vibes'] as int,
            dead_timer: e['dead_timer'] as String,
            beached_timer: e['beached_timer'] as String,
            inop_timer: e['inop_timer'] as String,
            undo_list: e['undo_list'] as String,
            redo_list: e['redo_list'] as String,
          ),
        )
        .toList();

    _isLoading = false;
    notifyListeners(); // Notify listeners to rebuild when this function runs
  } // searchData

  // Check to see if input match name already exists in the database
  Future<bool> checkMatchExists(String match) async {
    var result = await ScoutDatabase.matchData(ScoutDatabase.tableName, match);

    // Checking if the match exists
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // Insert a match into the database, using the match name in this class
  Future<String> insertMatch(String matchname) async {
    if (matchname == '') matchname = currentMatch;
    else matchname = await getNextUntitled();

    if (matchname.trim().isEmpty) {
      matchname = await getNextUntitled();
      if (_currentMatch.trim().isEmpty) {
         _currentMatch = matchname;
      }
    }

    final newMatch = ScoutModel(match_name: matchname, who_scouted: ''); // removed current scouter carry-over

    // Adding the match to database using the ScoutModel
    await ScoutDatabase.insertMatch(ScoutDatabase.tableName, newMatch.toMap());

    _nextUntitled = await getNextUntitled();

    // Adding the match to the list
    scoutItem.add(newMatch);

    notifyListeners(); // Notify listeners to rebuild when the function runs
    return matchname;
  } // insertMatch

  // Update data in the database using an inputted column and value
  Future updateData(String column, value) async {
    await ScoutDatabase.updateData(
        ScoutDatabase.tableName, currentMatch, column, value.toString());

    // Check if the team number is being updated, and update it in provider
    if (column == 'team') {
      _teamNum = value;
    } else if (column == 'who_scouted') {
      _currentScouter = value.toString();
    }

    _nextUntitled = await getNextUntitled();

    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Change the match name with an input of the initial name and the new name
  Future<void> changeMatch(String initialName, String newName) async {
    if (newName.trim().isEmpty) {
      newName = await getNextUntitled();
    }

    // Check if the current match is being changed, and update it if so
    if (initialName == _currentMatch) {
      _currentMatch = newName;
    }

    // Change the match name in the database
    await ScoutDatabase.updateData(
        ScoutDatabase.tableName, initialName, 'match_name', newName);

    // Update the item in the list if it exists
    final index = scoutItem.indexWhere((item) => item.match_name == initialName);
    if (index != -1) {
      scoutItem[index].match_name = newName;
    }

    _nextUntitled = await getNextUntitled();

    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Delete a match based on the input match name
  void deleteData(String matchName) async {
    await ScoutDatabase.deleteMatch(ScoutDatabase.tableName, matchName);
    scoutItem.removeWhere((item) => item.match_name == matchName);

    //check if the current match is being deleted, and if so set to the first match in the database
    if (matchName == currentMatch) {
      final dataList = await ScoutDatabase.selectSpecific(ScoutDatabase.tableName, '');
      if (dataList.isNotEmpty) {
        setMatch(dataList.first['match_name'] as String);
      } else {
        _currentMatch = '';
        _teamNum = 0;
        _currentScouter = '';
        await insertMatch('');
      }
    } else {
      notifyListeners(); // Notify listeners to rebuild when the function runs
    }
  }

  // Get a string from the database based on an input column
  Future<String> getStringData(String column) async {
    return ScoutDatabase.getStringData(
        ScoutDatabase.tableName, currentMatch, column);
  }

  // Get an int from the database based on an input column
  Future<int> getIntData(String column) async {
    int value = await ScoutDatabase.getIntData(ScoutDatabase.tableName, currentMatch, column);

    // Check if it is getting the team number, and setting it if so
    if (column == 'team') {
      _teamNum = value == -1 ? 0 : value;
    }

    return value;
  }

  Future<String> getNextUntitled() async {
    int earliest = 1;
    int matches = await ScoutDatabase.getMatchCount(ScoutDatabase.tableName);
    for (int i = 0; i < matches; i++) {
      if (await ScoutDatabase.hasMatch(
          ScoutDatabase.tableName, 'Untitled $earliest')) {
        earliest++;
      } else break;
    }

    return 'Untitled $earliest';
  }


  // Set the match and team number based on the input match name
  void setMatch(String matchName) async {
    if (matchName.trim().isEmpty && _currentMatch.isNotEmpty) return;
    if (matchName.trim().isEmpty) matchName = await getNextUntitled();
    _currentMatch = matchName;

    // Updating the team number
    int fetchedTeamNum = await ScoutDatabase.getIntData(
        ScoutDatabase.tableName, matchName, 'team');
    _teamNum = fetchedTeamNum == -1 ? 0 : fetchedTeamNum;

    String dbScouter = await ScoutDatabase.getStringData(
        ScoutDatabase.tableName, matchName, 'who_scouted');
        
    _currentScouter = dbScouter; // removed carry-over logic

    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Get a list of strings from the database for the QR code
  Future<List<String>> getQRData() async {
    var data =
        await ScoutDatabase.matchData(ScoutDatabase.tableName, currentMatch);

    List<String> dataList = [];

    if (data.isEmpty) {
      return [];
    }
    
    bool autoClimbed = true;

    // Run for the first (and only) row in the query called data
    data.first.forEach((key, value) {
      // Checking if it is the match_name column
      if (key == 'match_name') {
        // Making variable for the match name
        final match = value.toString();

        // Finding the last integer some string
        final RegExp regExp = RegExp(r'(\d+)(?!.*\d)');
        // Getting just the number from the match name
        final matchNum = regExp.firstMatch(match);

        // Adding the match number to the list<String> for QR
        dataList.add(matchNum?.group(0) ?? '0');
      } else if (key == 'start_side') {
        dataList.add((value.toString() == 'Left Trench' || value.toString() == 'Right Trench') ? '1' : '0');
        dataList.add((value.toString() == 'Left Bump' || value.toString() == 'Right Bump') ? '1' : '0');
        dataList.add((value.toString() == 'Hub') ? '1' : '0');
      } else if (key == 'intake_spots') {
        List<dynamic> spots = [];
        if (value.toString().isNotEmpty) {
          try {
            spots = jsonDecode(value.toString());
          } catch (e) {
            spots = [];
          }
        }
        dataList.add(spots.contains('outpost') ? '1' : '0');
        dataList.add(spots.contains('depot') ? '1' : '0');
        dataList.add(spots.contains('neutral') ? '1' : '0');
      } else if (key == 'climb_position' || key == 'auto_climb_position') {
        dataList.add(value.toString() == '0' ? '1' : '0');
        dataList.add(value.toString() == '1' ? '1' : '0');
        dataList.add(value.toString() == '2' ? '1' : '0');
      } else if (value.toString() == '-1' || value.toString() == '') {
        dataList.add('');
      } else if (key == 'climb_level') {
        dataList.add(value.toString() == '1' ? '1' : '0');
        dataList.add(value.toString() == '2' ? '1' : '0');
        dataList.add(value.toString() == '3' ? '1' : '0');
      }
      else if (key == 'undo_list' || key == 'redo_list' || key == 'fouls' || key == 'auto_climb_level') {
        // do nothing
      } else {
        // Adding whatever value it is to the list<String> for QR
        dataList.add(value.toString());
      }
    });

    return dataList;
  }
}

class TimerStateProvider extends ChangeNotifier {
  int _runningTimers = 0;
  bool _isToggle = false;
  SharedPreferencesAsync prefs = SharedPreferencesAsync();

  bool get isTimerRunning => _runningTimers > 0;
  bool get isToggle => _isToggle;

  Future<void> loadSettings() async {
    _isToggle = await prefs.getBool('toggle') ?? true;

    notifyListeners(); // Updates any listening widgets
  }

  void increment() {
    _runningTimers++;
    if (_runningTimers == 1) {
      notifyListeners();
    }
  }

  void decrement() {
    if (_runningTimers > 0) {
      _runningTimers--;
      if (_runningTimers == 0) {
        notifyListeners();
      }
    }
  }

  Future<void> toggleToggle() async {
    if (_runningTimers == 0) {
      _isToggle = !_isToggle;
      await prefs.setBool('toggle', _isToggle);
      notifyListeners();
    }
  }
}