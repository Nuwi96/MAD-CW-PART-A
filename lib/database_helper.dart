import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _dbName = 'toDoList.db';
  static final _dbVersion = 1;
  static final _tableName = 'noteTable';
  static final _columnId = 'id';
  static final _columnName = 'title';
  static final _columnName2 = 'note';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE $_tableName(
        $_columnId INTEGER PRIMARY KEY,
        $_columnName TEXT NOT NULL,
        $_columnName2 TEXT NOT NULL
      )
      ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps =
    await db.query(_tableName, columns: [_columnId, _columnName, _columnName2]);
    return maps;
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[_columnId];
    return await db
        .update(_tableName, row, where: '$_columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    db.delete(_tableName, where: '$_columnId = ?', whereArgs: [id]);
  }


}
