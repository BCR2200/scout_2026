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

  // Set a private and public teamNum
  int _teamNum = 0;
  int get teamNum => _teamNum;

  // Display all matches that contain the input search
  Future<void> searchData(String search) async {
    final dataList = await ScoutDatabase.selectSpecific(ScoutDatabase.tableName, search);

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
            placeholder: e['placeholder'] as String,
            notes: e['notes'] as String,
          ),
    ).toList();

    notifyListeners(); // Notify listeners to rebuild when this function runs
  } // searchData

  // Check to see if input match name already exists in the database
  Future<bool> checkMatchExists(String match) async {
    var result = await ScoutDatabase.matchData(ScoutDatabase.tableName, match);

    // Checking if the match exists
    if (result.isNotEmpty) {return true;}
    else {return false;}
  }

  // Insert a match into the database, using the match name in this class
  Future insertMatch() async {
    final newMatch = ScoutModel(match_name: currentMatch);

    // Adding the match to database using the ScoutModel
    ScoutDatabase.insertMatch(ScoutDatabase.tableName, newMatch.toMap());

    notifyListeners(); // Notify listeners to rebuild when the function runs
  } // insertMatch

  // Update data in the database using an inputted column and value
  Future updateData(String column, value) async {
     ScoutDatabase.updateData(ScoutDatabase.tableName, currentMatch, column, value.toString());

     // Check if the team number is being updated, and update it in provider
     if(column == 'team'){
       _teamNum = value;
     }
     
     notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Change the match name with an input of the initial name and the new name
  void changeMatch(String initialName, newName) {

    // Check if the current match is being changed, and update it if so
    if (initialName == currentMatch) {
      _currentMatch = newName;
    }

    // Change the match name in the database
    ScoutDatabase.updateData(ScoutDatabase.tableName, initialName, 'match_name', newName);

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
    ScoutDatabase.deleteMatch(ScoutDatabase.tableName, matchName);
    notifyListeners(); // Notify listeners to rebuild when the function runs
  }

  // Get a string from the database based on an input column
  Future<String> getStringData(String column) async {
    return ScoutDatabase.getStringData(
        ScoutDatabase.tableName, currentMatch, column);
  }

  // Get an int from the database based on an input column
  Future<int> getIntData(String column) async {
    Future<int> value = ScoutDatabase.getIntData(
        ScoutDatabase.tableName, currentMatch, column);

    // Check if it is getting the team number, and setting it if so
    if(column == 'team'){
      _teamNum = await value;
    }

    return value;
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

    var data = await ScoutDatabase.matchData(ScoutDatabase.tableName, currentMatch);
    List<String> dataList = [];

    // Run for the first (and only) row in the query called data
    data.first.forEach((key, value){

      // Checking if it is the match_name column
      if (key == 'match_name'){

        // Making variable for the match name
        final match = value.toString();

        // Finding the last integer some string
        final RegExp regExp = RegExp(r'(\d+)(?!.*\d)');
        // Getting just the number from the match name
        final matchNum = regExp.firstMatch(match);

        // Adding the match number to the list<String> for QR
        dataList.add(matchNum?.group(0) ?? '0');
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
