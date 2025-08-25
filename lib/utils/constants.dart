// deliberately desided not to add proper localization files
class TextConstants {
  static const appName = 'Rick and Morty characters';
  static const loadMore = 'Load More';
  static const characters = 'Characters';
  static const favorites = 'Favorites';
  static const error = 'Error: ';
  static const retry = 'Retry';
}

class ApiConstants {
  static const String api = 'https://rickandmortyapi.com/api';
  static const String character = '/character';
  static const String location = '/location';
  static const String episode = '/episode';
  static const String pageParameter = '?page=';
}

class SqlConstants {
  static const String urlCheck = "CHECK (url LIKE 'http%' OR url LIKE 'https%'";
}

class TableNameConstants {
  static const String characters = 'characters';
  static const String episodes = 'episodes';
  static const String locations = 'locations';
  static const String origins = 'origins';
}

class KeysConstants {
  static const String count = 'count';
  static const String pages = 'pages';
  static const String next = 'next';
  static const String prev = 'prev';
  static const String isDark = 'is_dark';
}
