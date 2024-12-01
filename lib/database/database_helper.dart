import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'user_profile.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        profile_picture TEXT
      );
    ''');
  }

  // Insert profile into the database
  Future<int> insertProfile(Map<String, dynamic> profile) async {
    Database db = await database;
    return await db.insert('Profile', profile);
  }

  // Fetch profile from the database
  Future<Map<String, dynamic>?> getProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('Profile');
    return result.isNotEmpty ? result.first : null;
  }

  // Update profile in the database
  Future<int> updateProfile(Map<String, dynamic> profile) async {
    Database db = await database;
    return await db.update('Profile', profile, where: 'id = ?', whereArgs: [profile['id']]);
  }

  // Delete profile from the database
  Future<int> deleteProfile(int id) async {
    Database db = await database;
    return await db.delete('Profile', where: 'id = ?', whereArgs: [id]);
  }
}
