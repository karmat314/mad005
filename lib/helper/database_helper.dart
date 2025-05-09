// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Generated with help of ChatGPT
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'scanned_docs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            filePath TEXT,
            tag TEXT,
            dateScanned TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertDocument(Map<String, dynamic> doc) async {
    final db = await database;
    return await db.insert('documents', doc);
  }

  Future<List<Map<String, dynamic>>> getAllDocuments() async {
    final db = await database;
    return await db.query('documents', orderBy: 'dateScanned DESC');
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }
}
