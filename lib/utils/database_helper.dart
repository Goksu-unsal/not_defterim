import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:not_sepeti/models/category.dart';
import 'package:not_sepeti/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  Database _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper.internal();
      return _databaseHelper;
    } else
      return _databaseHelper;
  }

  DatabaseHelper.internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDb();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database> _initializeDb() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notes.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notes_asset.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    _database = await openDatabase(path, readOnly: false);
    return _database;
  }
  //Category işlemleri
  Future<List<Category>> getCategoryList() async {
    var db = await _getDatabase();
    var result = await db.query("categories_table");
    return List.generate(
        result.length, (index) => Category.fromMap(result[index]));
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();
    int result = await db.insert("categories_table", category.toMap());
    return result;
  }

  Future<int> updateCategory(Category cat) async {
    var db = await _getDatabase();
    var result = await db.update("categories_table", cat.toMap(),
        where: "category_id = ?", whereArgs: [cat.categoryId]);
    return result;
  }

  Future<int> deleteCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.delete("categories_table",
        where: "category_id = ?", whereArgs: [category.categoryId]);
    return result;
  }
  //Note işlemleri
  Future<List<Note>> getNoteList() async {
    var db = await _getDatabase();
    var result = await db.rawQuery("select * from notes_table inner join categories_table on categories_table.category_id = notes_table.cathegory_id");
    return List.generate(result.length, (index) => Note.fromMap(result[index]));
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();
    int result = await db.insert("notes_table", note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();
    var result = await db.update("notes_table", note.toMap(),
        where: "note_id = ?", whereArgs: [note.noteId]);
    return result;
  }

  Future<int> deleteNote(Note note) async {
    var db = await _getDatabase();
    var result = await db.delete("notes_table",
        where: "note_id = ?", whereArgs: [note.noteId]);
    return result;
  }
}
