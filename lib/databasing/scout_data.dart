/*
 * Ensure these column names are unchanged (order can differ though)
 * 
 * team
 * match_name
 * defence
 * drive_rating
 * fouls
 * notes
 *
 * The rest of the column names are there as examples of common FRC columns
**/

import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';

// TODO UPDATE
// This is the model for all the data, since it is easiest to convert this way
// Whenever you want to add a "column" of data, just add it here and where it says
// ATTENTION in the database below and the provider_service file
class ScoutModel {
   int team,
      defence,
      drive_rating,
      died,
      fouls,
      auto_climb_level,
      auto_climb_position,
      climb_level,
      climb_position,
      is_blue,
      offense;

   String match_name, notes, placeholder, auto_volleys, volleys, main_role, who_scouted;

  ScoutModel({
    this.team = 0,
    required this.match_name,
    this.defence = 0,
    this.drive_rating = -1,
    this.died = 0,
    this.fouls = 0,
    this.auto_climb_level = 0,
    this.auto_climb_position = 1,
    this.climb_level = 0,
    this.climb_position = 1,
    this.auto_volleys = '',
    this.volleys = '',
    this.placeholder = '',
    this.notes = ' ',
    this.is_blue = 0,
    this.main_role = 'Defence',
    this.offense = 0,
    this.who_scouted = ' ',
  });

  Map<String, Object> toMap() {
    return {
      'team': team,
      'match_name': match_name,
      'defence': defence,
      'drive_rating': drive_rating,
      'died': died,
      'fouls': fouls,
      'auto_climb_level': auto_climb_level,
      'auto_climb_position': auto_climb_position,
      'climb_level': climb_level,
      'climb_position': climb_position,
      'placeholder': placeholder,
      'notes': notes,
      'auto_volleys': auto_volleys,
      'volleys': volleys,
      'is_blue': is_blue,
      'main_role': main_role,
      'offense': offense,
      'who_scouted': who_scouted,
    };
  }
}


// This class is used to interact with the database wherever needed
class ScoutDatabase {
  static const tableName = 'scout_data_2025'; // Constant table name

  // This is the method that gives the database
  static Future<Database> scoutDatabase() async {
    final databaseDirPath = await getDatabasesPath(); // Get directory path
    WidgetsFlutterBinding.ensureInitialized(); // Ensure initialized so no error

    // Opening or initially creating the database, labelled scout_db.db
    return await openDatabase(
      join(databaseDirPath, "scout_db.db"),
      
      /* =================================*
      *             ATTENTION            *
      * =================================*
      *  
      * This is the location you'll have to manually change the database tables 
      * If you see below, there is a large block of text
      * Just simply follow the same logical flow as the elements already there
      * but with the elements you want to add, and it should work just fine
      * Oh, and make sure their order is the same as what's on the spreadsheets
      * And double check deleting the ones I already provided,
      * most of them are used in the shell
      * 
      **/

      // Creating the database
      //defence is the main role but haven't updated the text here yet
      onCreate: (Database db, int version) async {
        await db.execute('''
        CREATE TABLE $tableName (
        team INTEGER NOT NULL,
        match_name TEXT NOT NULL PRIMARY KEY,
        auto_climb_level INTEGER NOT NULL,
        auto_climb_position INTEGER NOT NULL,
        auto_volleys TEXT,
        volleys TEXT,
        climb_level INTEGER NOT NULL,
        climb_position INTEGER NOT NULL,
        fouls INTEGER NOT NULL,
        placeholder TEXT,
        is_blue INTEGER NOT NULL,
        drive_rating INTEGER NOT NULL,
        main_role TEXT NOT NULL,
        defence INTEGER NOT NULL,
        offense INTEGER NOT NULL,
        died INTEGER NOT NULL,
        notes TEXT,
        who_scouted TEXT
        )
        ''');
      },
      version: 1,
    );
  } // scoutDatabase

  // Shows all matches that align with the search
  static Future<List<Map<String, dynamic>>> selectSpecific(String table, String search) async {
    final db = await ScoutDatabase.scoutDatabase();

    // Selects matches with the search parameter (and of course not empty match)
    return db.rawQuery('''SELECT * FROM $table 
    WHERE NOT match_name = ? AND 
    match_name LIKE ?
    ORDER BY match_name''', ['', '%$search%']);
  }

  // This will send back the data of a match in its queried form
  static Future<List<Map<String, dynamic>>> matchData(String table, String match) async {
    final db = await ScoutDatabase.scoutDatabase();
    return db.rawQuery("SELECT * FROM $table WHERE match_name = ?",[match]);
  }

  // Adding an empty match to the database
  static Future addEmptyMatch() async {
    final db = await ScoutDatabase.scoutDatabase();
    final emptyMatch = ScoutModel(match_name: '');
    return db.insert(
      tableName,
      emptyMatch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace
    );

  }

  // Function that will insert a match into the database (with inputted data)
  static Future insertMatch(String table, Map<String, Object> data) async {
    final db = await ScoutDatabase.scoutDatabase();
    return db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.ignore, // Does nothing if the match already exists
    );
  }

  // Updating data in the database (changing a value based on table, matchname, column, and new value)
  static Future updateData(String table, String matchName, String column, String value) async {
    final db = await ScoutDatabase.scoutDatabase();
    return await db.rawUpdate('UPDATE $table SET $column=? WHERE match_name = ?', [value, matchName]);
  }

  // Deleting a match in the database based on the match name
  static Future deleteMatch(String table, String matchName) async {
    final db = await ScoutDatabase.scoutDatabase();
    return await db.rawDelete('DELETE FROM $table WHERE match_name=?', [matchName]);
  }

  // Getting the data for a string from the database
  static Future<String> getStringData(String table, String matchName, String column) async {
    final db = await ScoutDatabase.scoutDatabase();
    final result = await db.rawQuery('SELECT $column FROM $table WHERE match_name=?', [matchName]);
    String data = result.first[column].toString();
    return data;
  }

  // Getting the data for an int from the database
  static Future<int> getIntData(String table, String matchName, String column) async {
    final db = await ScoutDatabase.scoutDatabase();
    final result = await db.rawQuery('SELECT $column FROM $table WHERE match_name=?', [matchName]);
    int data = Sqflite.firstIntValue(result) ?? 0; // If null, just set it to be 0 (the usual default)
    return data;
  }
}