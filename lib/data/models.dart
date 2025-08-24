import 'package:em_tth_assignment/main.dart';

class CharacterInfoAndData {
  final CharacterInfo info;
  final List<Character> results;

  CharacterInfoAndData({required this.info, required this.results});

  factory CharacterInfoAndData.fromMap(Map<String, dynamic> map) {
    try {
      return CharacterInfoAndData(
        info: CharacterInfo.fromMap(map['info'] as Map<String, dynamic>),
        results: (map['results'] as List).map((item) => Character.fromMap(item as Map<String, dynamic>)).toList(),
      );
    } catch (error, stack) {
      logger.e('''
         Error in CharacterInfoAndData.fromMap: 
         Error: $error,
         Stack: $stack,
         Parameters:
            map: $map
       ''');
      rethrow;
    }
  }
}

class CharacterInfo {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  CharacterInfo({required this.count, required this.pages, required this.next, required this.prev});

  factory CharacterInfo.fromMap(Map<String, dynamic> map) {
    return CharacterInfo(
      count: map['count'] as int,
      pages: map['pages'] as int,
      next: map['next'] as String?,
      prev: map['prev'] as String?,
    );
  }
}

class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final Origin origin;
  final Location location;
  final String image;
  final List<String> episode;
  final String url;
  final DateTime created;
  final bool isFavorite;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
    required this.episode,
    required this.url,
    required this.created,
    this.isFavorite = false,
  });

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as int,
      name: map['name'] as String,
      status: map['status'] as String,
      species: map['species'] as String,
      type: map['type'] as String,
      gender: map['gender'] as String,
      origin: Origin.fromMap(map['origin'] as Map<String, dynamic>),
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
      image: map['image'] as String,
      episode: List<String>.from(map['episode'] as List),
      url: map['url'] as String,
      created: DateTime.parse(map['created'] as String),
    );
  }
}

class Origin {
  final String name;
  final String url;

  Origin({required this.name, required this.url});

  factory Origin.fromMap(Map<String, dynamic> map) {
    return Origin(name: map['name'] as String, url: map['url'] as String);
  }
}

class Location {
  final String name;
  final String url;

  Location({required this.name, required this.url});

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(name: map['name'] as String, url: map['url'] as String);
  }
}
