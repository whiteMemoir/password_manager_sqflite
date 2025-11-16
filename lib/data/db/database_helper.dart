import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import '../models/password.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'password_manager.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE passwords (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            username TEXT,
            password TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertPassword(Password password) async {
    final db = await database;
    await db.insert('passwords', password.toMap());
  }

  Future<List<Password>> getPasswords() async {
    final db = await database;
    final maps = await db.query('passwords', orderBy: 'id DESC');
    return List.generate(maps.length, (i) => Password.fromMap(maps[i]));
  }

  Future<void> updatePassword(Password password) async {
    final db = await database;
    await db.update(
      'passwords',
      password.toMap(),
      where: 'id = ?',
      whereArgs: [password.id],
    );
  }

  Future<void> deletePassword(int id) async {
    final db = await database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}
