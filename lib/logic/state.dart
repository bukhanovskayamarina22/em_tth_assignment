import 'package:em_tth_assignment/data/models.dart';
import 'package:equatable/equatable.dart';

abstract class CharactersState extends Equatable {
  const CharactersState();

  @override
  List<Object> get props => [];
}

class CharactersInitial extends CharactersState {
  const CharactersInitial();
}

class CharactersLoading extends CharactersState {
  const CharactersLoading();
}

class CharactersLoadingMore extends CharactersState {
  final List<Character> characters;
  final int currentPage;

  const CharactersLoadingMore({required this.characters, required this.currentPage});

  @override
  List<Object> get props => [characters, currentPage];
}

class CharactersLoaded extends CharactersState {
  final List<Character> characters;
  final CharacterInfo info;
  final int currentPage;
  final bool hasReachedMax;

  const CharactersLoaded({
    required this.characters,
    required this.info,
    required this.currentPage,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [characters, info, currentPage, hasReachedMax];

  CharactersLoaded copyWith({List<Character>? characters, CharacterInfo? info, int? currentPage, bool? hasReachedMax}) {
    return CharactersLoaded(
      characters: characters ?? this.characters,
      info: info ?? this.info,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class FavoriteCharactersLoaded extends CharactersState {
  final List<Character> characters;
  final CharacterInfo info;
  final int currentPage;
  final bool hasReachedMax;

  const FavoriteCharactersLoaded({
    required this.characters,
    required this.info,
    required this.currentPage,
    required this.hasReachedMax,
  });

  @override
  List<Object> get props => [characters, info, currentPage, hasReachedMax];

  FavoriteCharactersLoaded copyWith({
    List<Character>? characters,
    CharacterInfo? info,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return FavoriteCharactersLoaded(
      characters: characters ?? this.characters,
      info: info ?? this.info,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}
