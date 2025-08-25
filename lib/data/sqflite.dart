import 'package:em_tth_assignment/utils/constants.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String dbName = 'characters.db';
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = '${await getDatabasesPath()}$dbName';
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // TODO: refactor all the keywords out
      //TODO: move url check out
      await txn.execute('''
     CREATE TABLE ${TableNameConstants.origins} (
       id INTEGER PRIMARY KEY,
       name TEXT NOT NULL UNIQUE,
       url TEXT NOT NULL UNIQUE CHECK (url LIKE 'http%' OR url LIKE 'https%')
     )
   ''');

      await txn.execute('''
    CREATE TABLE ${TableNameConstants.locations} (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      url TEXT NOT NULL UNIQUE CHECK (url LIKE 'http%' OR url LIKE 'https%')
    )
  ''');

      await txn.execute('''
    CREATE TABLE ${TableNameConstants.episodes} (
      id INTEGER PRIMARY KEY,
      url TEXT NOT NULL UNIQUE CHECK (url LIKE 'http%' OR url LIKE 'https%')
    )
  ''');

      await txn.execute('''
    CREATE TABLE ${TableNameConstants.characters} (
      id INTEGER PRIMARY KEY,
      api_id INTEGER NOT NULL UNIQUE,
      name TEXT NOT NULL UNIQUE,
      status TEXT NOT NULL,
      species TEXT NOT NULL,
      type TEXT NOT NULL,
      gender TEXT NOT NULL,
      origin_id INTEGER,
      location_id INTEGER,
      image TEXT NOT NULL UNIQUE,
      created DATETIME NOT NULL,
      episode_id INTEGER,
      url TEXT CHECK (url LIKE 'http%' OR url LIKE 'https%'),
      is_favorite BOOL NOT NULL DEFAULT false,
      FOREIGN KEY (origin_id) REFERENCES origins (id),
      FOREIGN KEY (location_id) REFERENCES locations (id),
      FOREIGN KEY (episode_id) REFERENCES episodes (id)
    )
  ''');
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> delete() async {
    final dbPath = '${await getDatabasesPath()}characters.db';
    await close();
    await deleteDatabase(dbPath);
    _database = null;
  }
}
