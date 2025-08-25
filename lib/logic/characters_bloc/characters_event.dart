import 'package:equatable/equatable.dart';

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

class ChangeCharacterFavorite extends CharactersEvent {
  final int id;
  final bool isFavorite;

  const ChangeCharacterFavorite({required this.id, required this.isFavorite});
}
