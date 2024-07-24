import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

part 'database_helper.g.dart';

@Riverpod(keepAlive: true)
DatabaseHelper dbHelper(DbHelperRef ref) {
  return DatabaseHelper.instance;
}

class DatabaseHelper {
  static const _databaseName = "MinimalTodoDatabase.db";
  static const databaseVersion = 2;

  static const todoTable = 'todos';

  static const columnTodoId = 'id';
  static const columnTodoText = 'text';
  static const columnTodoIndex = 'todoIndex';
  static const columnDueDateTime = 'dueDateTime';
  static const columnIsTimeSetByUser = 'isTimeSetByUser';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  @visibleForTesting
  void testSetDatabase(Database db) {
    _database = db;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: databaseVersion, onCreate: onCreate, onUpgrade: onUpgrade);
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $todoTable (
          $columnTodoId TEXT PRIMARY KEY,
          $columnTodoText TEXT NOT NULL,
          $columnTodoIndex INTEGER NOT NULL,
          $columnDueDateTime TEXT,
          $columnIsTimeSetByUser INTEGER
          )
          ''');
  }

  Future onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      ALTER TABLE $todoTable ADD COLUMN $columnDueDateTime TEXT
      ''');
      await db.execute('''
      ALTER TABLE $todoTable ADD COLUMN $columnIsTimeSetByUser INTEGER
      ''');
    }
  }
}
