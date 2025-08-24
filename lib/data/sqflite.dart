import 'package:em_tth_assignment/data/models.dart';
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

class CharacterService {
  final helper = DatabaseHelper();

  Future<List<Character>> getAllCharacters() async {
    final Database db = await helper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.id,
        c.api_id,
        c.name,
        c.status,
        c.species,
        c.type,
        c.gender,
        c.image,
        c.created,
        c.url,
        c.is_favorite,
        o.name as origin_name,
        o.url as origin_url,
        l.name as location_name,
        l.url as location_url,
        e.url as episode_url
      FROM ${TableNameConstants.characters} c
      LEFT JOIN ${TableNameConstants.origins} o ON c.origin_id = o.id
      LEFT JOIN ${TableNameConstants.locations} l ON c.location_id = l.id
      LEFT JOIN ${TableNameConstants.episodes} e ON c.episode_id = e.id
      ORDER BY c.api_id ASC
    ''');

    return maps.map((map) => _mapToCharacterResponse(map)).toList();
  }

  Future<Character?> getCharacterById(int id) async {
    final Database db = await helper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT 
        c.id,
        c.api_id,
        c.name,
        c.status,
        c.species,
        c.type,
        c.gender,
        c.image,
        c.created,
        c.url,
        c.is_favorite,
        o.name as origin_name,
        o.url as origin_url,
        l.name as location_name,
        l.url as location_url,
        e.url as episode_url
      FROM ${TableNameConstants.characters} c
      LEFT JOIN ${TableNameConstants.origins} o ON c.origin_id = o.id
      LEFT JOIN ${TableNameConstants.locations} l ON c.location_id = l.id
      LEFT JOIN ${TableNameConstants.episodes} e ON c.episode_id = e.id
      WHERE c.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return _mapToCharacterResponse(maps.first);
    }
    return null;
  }

  Future<List<Character>> getFavoriteCharacters() async {
    final Database db = await helper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.id,
        c.api_id,
        c.name,
        c.status,
        c.species,
        c.type,
        c.gender,
        c.image,
        c.created,
        c.url,
        c.is_favorite,
        o.name as origin_name,
        o.url as origin_url,
        l.name as location_name,
        l.url as location_url,
        e.url as episode_url
      FROM ${TableNameConstants.characters} c
      LEFT JOIN ${TableNameConstants.origins} o ON c.origin_id = o.id
      LEFT JOIN ${TableNameConstants.locations} l ON c.location_id = l.id
      LEFT JOIN ${TableNameConstants.episodes} e ON c.episode_id = e.id
      WHERE c.is_favorite = 1
      ORDER BY c.api_id ASC
    ''');

    return maps.map((map) => _mapToCharacterResponse(map)).toList();
  }

  Future<int> deleteCharacterById(int id) async {
    final Database db = await helper.database;
    return db.delete(TableNameConstants.characters, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateCharacterById(int id, Character character) async {
    final Database db = await helper.database;

    int? originId;
    if (character.origin.name.isNotEmpty && character.origin.url.isNotEmpty) {
      originId = await _insertOrGetOrigin(db, character.origin);
    }

    int? locationId;
    if (character.location.name.isNotEmpty && character.location.url.isNotEmpty) {
      locationId = await _insertOrGetLocation(db, character.location);
    }

    int? episodeId;
    if (character.episode.isNotEmpty) {
      episodeId = await _insertOrGetEpisode(db, character.episode.first);
    }

    final Map<String, dynamic> characterData = {
      'api_id': character.id,
      'name': character.name,
      'status': character.status,
      'species': character.species,
      'type': character.type,
      'gender': character.gender,
      'origin_id': originId,
      'location_id': locationId,
      'image': character.image,
      'created': character.created.toIso8601String(),
      'episode_id': episodeId,
      'url': character.url,
      'is_favorite': character.isFavorite ? 1 : 0,
    };

    return db.update(TableNameConstants.characters, characterData, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> writeCharacters(List<Character> characters) async {
    final Database db = await helper.database;

    await db.transaction((txn) async {
      for (final Character character in characters) {
        int? originId;
        if (character.origin.name.isNotEmpty && character.origin.url.isNotEmpty) {
          originId = await _insertOrGetOrigin(txn, character.origin);
        }

        int? locationId;
        if (character.location.name.isNotEmpty && character.location.url.isNotEmpty) {
          locationId = await _insertOrGetLocation(txn, character.location);
        }

        int? episodeId;
        if (character.episode.isNotEmpty) {
          episodeId = await _insertOrGetEpisode(txn, character.episode.first);
        }

        final Map<String, dynamic> characterData = {
          'api_id': character.id,
          'name': character.name,
          'status': character.status,
          'species': character.species,
          'type': character.type,
          'gender': character.gender,
          'origin_id': originId,
          'location_id': locationId,
          'image': character.image,
          'created': character.created.toIso8601String(),
          'episode_id': episodeId,
          'url': character.url,
          'is_favorite': character.isFavorite ? 1 : 0,
        };

        await txn.insert(TableNameConstants.characters, characterData, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Character _mapToCharacterResponse(Map<String, dynamic> map) {
    return Character(
      id: map['api_id'] ?? 0,
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      species: map['species'] ?? '',
      type: map['type'] ?? '',
      gender: map['gender'] ?? '',
      origin: Origin(name: map['origin_name'] ?? '', url: map['origin_url'] ?? ''),
      location: Location(name: map['location_name'] ?? '', url: map['location_url'] ?? ''),
      image: map['image'] ?? '',
      episode: map['episode_url'] != null ? [map['episode_url']] : [],
      url: map['url'] ?? '',
      created: DateTime.parse(map['created'] ?? DateTime.now().toIso8601String()),
      isFavorite: (map['is_favorite'] ?? 0) == 1,
    );
  }

  Future<int> _insertOrGetOrigin(DatabaseExecutor db, Origin origin) async {
    final List<Map<String, dynamic>> existing = await db.query(
      TableNameConstants.origins,
      where: 'url = ?',
      whereArgs: [origin.url],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'];
    }

    return db.insert(TableNameConstants.origins, {'name': origin.name, 'url': origin.url});
  }

  Future<int> _insertOrGetLocation(DatabaseExecutor db, Location location) async {
    final List<Map<String, dynamic>> existing = await db.query(
      TableNameConstants.locations,
      where: 'url = ?',
      whereArgs: [location.url],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'];
    }

    return db.insert(TableNameConstants.locations, {'name': location.name, 'url': location.url});
  }

  Future<int> _insertOrGetEpisode(DatabaseExecutor db, String episodeUrl) async {
    final List<Map<String, dynamic>> existing = await db.query(
      TableNameConstants.episodes,
      where: 'url = ?',
      whereArgs: [episodeUrl],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'];
    }

    return db.insert(TableNameConstants.episodes, {'url': episodeUrl});
  }
}
