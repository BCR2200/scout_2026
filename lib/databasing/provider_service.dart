import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
            died: e['died'] as int,
            fouls: e['fouls'] as int,
            auto_climb_level: e['auto_climb_level'] as int,
            auto_climb_position: e['auto_climb_position'] as int,
            climb_level: e['climb_level'] as int,
            climb_position: e['climb_position'] as int,
            placeholder: e['placeholder'] as String,
            notes: e['notes'] as String,
            auto_volleys: e['auto_volleys'] as String,
            volleys: e['volleys'] as String,
            main_role: e['main_role'] as String,
            offense: e['offense'] as int,
            who_scouted: e['who_scouted'] as String,
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
  Future insertMatch(String matchname) async {
    if (matchname == '') matchname = currentMatch;
    else matchname = await getNextUntitled();

    final newMatch = ScoutModel(match_name: matchname);

    // Adding the match to database using the ScoutModel
    ScoutDatabase.insertMatch(ScoutDatabase.tableName, newMatch.toMap());

    _nextUntitled = await getNextUntitled();

    // Adding the match to the list
    scoutItem.add(newMatch);

    notifyListeners(); // Notify listeners to rebuild when the function runs
  } // insertMatch

  // Update data in the database using an inputted column and value
  Future updateData(String column, value) async {
    ScoutDatabase.updateData(
        ScoutDatabase.tableName, currentMatch, column, value.toString());

    // Check if the team number is being updated, and update it in provider
    if (column == 'team') {
      _teamNum = value;
    }

    _nextUntitled = await getNextUntitled();

    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Change the match name with an input of the initial name and the new name
  Future<void> changeMatch(String initialName, String newName) async {
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

    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Delete a match based on the input match name
  void deleteData(String matchName) async {
    //check if the current match is being deleted, and if so set to failsafe
    if (matchName == currentMatch) {
      _currentMatch = '';
      _teamNum = await ScoutDatabase.getIntData(
          ScoutDatabase.tableName, _currentMatch, 'team');
    }
    await ScoutDatabase.deleteMatch(ScoutDatabase.tableName, matchName);
    scoutItem.removeWhere((item) => item.match_name == matchName);
    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Get a string from the database based on an input column
  Future<String> getStringData(String column) async {
    return ScoutDatabase.getStringData(
        ScoutDatabase.tableName, currentMatch, column);
  }

  // Get an int from the database based on an input column
  Future<int> getIntData(String column) async {
    Future<int> value =
        ScoutDatabase.getIntData(ScoutDatabase.tableName, currentMatch, column);

    // Check if it is getting the team number, and setting it if so
    if (column == 'team') {
      _teamNum = await value;
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
    _currentMatch = matchName;

    // Updating the team number
    _teamNum = await ScoutDatabase.getIntData(
        ScoutDatabase.tableName, matchName, 'team');
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
      } else if (key == 'climb_position' || key == 'auto_climb_position') {
        if (value.toString() == '0') dataList.add('Left');
        else if (value.toString() == '1') dataList.add('Middle');
        else dataList.add('Right');
      }
      else if (key == 'volleys' || key == 'auto_volleys') {
        String volleyString = value.toString();
        if (volleyString.isNotEmpty && volleyString != '[]') {
          try {
            List<dynamic> volleys = jsonDecode(volleyString);
            if (volleys.isNotEmpty &&
                volleys[0] is List &&
                (volleys[0] as List).isNotEmpty &&
                volleys[0][0] is String) {
              List<List<dynamic>> convertedVolleys = volleys.map((v) {
                int typeAsInt;
                switch (v[0]) {
                  case 'volley':
                    typeAsInt = 0;
                    break;
                  case 'harvest':
                    typeAsInt = 2;
                    break;
                  case 'pass':
                    typeAsInt = 1;
                    break;
                  default:
                    typeAsInt = -1; // Or some other default
                }
                return [typeAsInt, v[1], v[2], v[3]];
              }).toList();
              List<int> vData = [
                0,
                0,
                0,
                0
              ]; // 0: home count, 1: neutral count, 2: opp count, 3: total hopper %
              double totalAcc = 0.0;
              double totalIn = 0.0;
              int numVolleys = 0;
              for (List<dynamic> v in volleys) {
                vData[v[3]]++;
                if (v[0] == 'volley') {
                  numVolleys++;
                  vData[3] += (v[1] as num).toInt();
                  totalAcc += (v[2] as num).toDouble();
                  totalIn +=
                      (v[1] as num).toDouble() * (v[2] as num).toDouble() * 0.01;
                }
              }
              totalAcc /= numVolleys;
              dataList.add(jsonEncode(convertedVolleys));
              dataList.add(vData[0].toString());
              dataList.add(vData[1].toString());
              dataList.add(vData[2].toString());
              dataList.add("${vData[3]}%");
              dataList.add("${((totalAcc*10).round()/10)}%");
              dataList.add("${((totalIn*10).round()/10)}%");
            } else {
              dataList.add(volleyString);
            }
          } catch (e) {
            dataList.add(volleyString);
          }
        } else {
          dataList.add(volleyString);
        }
      } else if (value.toString() == '-1') {
        dataList.add('');
      } else {
        // Adding whatever value it is to the list<String> for QR
        dataList.add(value.toString());
      }
    });

    return dataList;
  }
}
