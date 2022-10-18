import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'models/MountainActivity.dart';

class DatabaseHelper {
  static const _databaseName = "Gipfelbuch.db";
  static const _dabaseVersion = 1;

  // This is a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    debugPrint("init database");
    Directory appDir = await getApplicationDocumentsDirectory();
    String path = join(appDir.path, _databaseName);
    return await openDatabase(
      path,
      version: _dabaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    debugPrint('Creating Database');
    await db.execute('''
      CREATE TABLE mountain_activities(
        id INTEGER PRIMARY KEY,
        mountainName TEXT,
        participants TEXT,
        date INTEGER,
        distance REAL,
        duration REAL,
        climb INTEGER,
        latitude REAL,
        longitude REAL
    )''');
  }

  Future<List<MountainActivity>> getAllActivities() async{
    Database db = await instance.database;
    var activities = await db.query('mountain_activities', orderBy: 'date DESC' );
    List<MountainActivity> list = activities.isNotEmpty ? activities.map((e) => MountainActivity.fromMap(e)).toList() : [];
    return list;
  }

  Future<int> addActivity(MountainActivity activity) async{
    Database db = await instance.database;
    return await db.insert('mountain_activities', activity.toMap());
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete('mountain_activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(MountainActivity activity) async {
    Database db = await instance.database;
    return await db.update('mountain_activities', activity.toMap(), where: 'id = ?', whereArgs: [activity.id]);
  }
}