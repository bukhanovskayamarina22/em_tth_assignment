import 'package:equatable/equatable.dart';

//TODO: if they end up having no parameters - change to an enum
abstract class CharactersEvent extends Equatable {
  const CharactersEvent();

  @override
  List<Object> get props => [];
}

class LoadAllCharacters extends CharactersEvent {
  const LoadAllCharacters();
}

class LoadNextPage extends CharactersEvent {
  const LoadNextPage();
}

class RefreshCharacters extends CharactersEvent {
  const RefreshCharacters();
}

class LoadFavoriteCharacters extends CharactersEvent {
  const LoadFavoriteCharacters();
}
