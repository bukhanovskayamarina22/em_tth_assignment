import 'package:bloc/bloc.dart';
import 'package:em_tth_assignment/data/db/characters_service.dart';
import 'package:em_tth_assignment/data/http/api_service.dart';
import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_event.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_state.dart';
import 'package:em_tth_assignment/main.dart';

class CharacterBloc extends Bloc<CharactersEvent, CharactersState> {
  final ApiService _apiService;
  final PreferencesHelper _preferencesHelper;
  final CharactersService _charactersService;

  CharacterBloc({
    required ApiService apiService,
    required PreferencesHelper preferencesHelper,
    required CharactersService charactersService,
  }) : _apiService = apiService,
       _preferencesHelper = preferencesHelper,
       _charactersService = charactersService,
       super(const CharactersInitial()) {
    on<LoadAllCharacters>(_onLoadCharacters);
    on<LoadFavoriteCharacters>(_onLoadFavoriteCharacters);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshCharacters>(_onRefreshCharacters);
    on<ChangeCharacterFavorite>(_onChangeCharacterFavorite);
  }

  Future<void> _onLoadCharacters(LoadAllCharacters event, Emitter<CharactersState> emit) async {
    emit(const CharactersLoading());
    final savedCharacters = await _charactersService.getAllCharacters();
    if (savedCharacters.isEmpty) {
      await _fetchCharacters(emit, 1, []);
    } else {
      final info = await _preferencesHelper.getInfo();
      final page = savedCharacters.length ~/ 20;
      final hasReachedMax = getHasReachedMax(page: page, info: info);

      emit(CharactersLoaded(characters: savedCharacters, info: info, currentPage: page, hasReachedMax: hasReachedMax));
    }
  }

  Future<void> _onLoadFavoriteCharacters(LoadFavoriteCharacters event, Emitter<CharactersState> emit) async {
    final List<Character> characters = await _getFavoriteCharacters();
    emit(FavoriteCharactersLoaded(characters: characters));
  }

  Future<List<Character>> _getFavoriteCharacters() async {
    try {
      final characters = await _charactersService.getFavoriteCharacters();
      return characters;
    } catch (error, stack) {
      logger.e('''
       Error in CharacterBloc._fetchCharacters: 
       Error: $error,
       Stack: $stack,
       ''');
      rethrow;
    }
  }

  Future<void> _onLoadNextPage(LoadNextPage event, Emitter<CharactersState> emit) async {
    if (state is CharactersLoaded) {
      final currentState = state as CharactersLoaded;

      if (currentState.hasReachedMax) return;

      emit(CharactersLoadingMore(characters: currentState.characters, currentPage: currentState.currentPage));

      await _fetchCharacters(emit, currentState.currentPage + 1, currentState.characters);
    }
  }

  Future<void> _onRefreshCharacters(RefreshCharacters event, Emitter<CharactersState> emit) async {
    emit(const CharactersLoading());
    await _fetchCharacters(emit, 1, []);
  }

  Future<void> _fetchCharacters(Emitter<CharactersState> emit, int page, List<Character> existingCharacters) async {
    try {
      final response = await _apiService.getCharacters(page: page);

      await _saveToPreferences(response.info);
      await _writeCharacters(response.results);

      final allCharacters = page == 1 ? response.results : [...existingCharacters, ...response.results];

      final hasReachedMax = getHasReachedMax(page: page, info: response.info);

      emit(
        CharactersLoaded(
          characters: allCharacters,
          info: response.info,
          currentPage: page,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (error, stack) {
      logger.e('''
       Error in CharacterBloc._fetchCharacters: 
       Error: $error,
       Stack: $stack,
       Parameters:
          page: $page,
          existingCharacters: $existingCharacters
       ''');
      emit(
        CharactersError(
          message: error.toString(),
          characters: existingCharacters,
          currentPage: page > 1 ? page - 1 : 1,
        ),
      );
    }
  }

  Future<void> _onChangeCharacterFavorite(ChangeCharacterFavorite event, Emitter<CharactersState> emit) async {
    await _updateCharacterFavorite(id: event.id, isFavorite: event.isFavorite);
    List<Character> characters = [];
    if (state is CharactersLoaded) {
      final currentState = state as CharactersLoaded;
      characters = [...currentState.characters];
      final index = characters.indexWhere((c) => c.id == event.id);
      final updatedCharacter = characters[index].copyWith(isFavorite: event.isFavorite);
      characters[index] = updatedCharacter;
      emit(currentState.copyWith(characters: characters));
    } else if (state is FavoriteCharactersLoaded) {
      final characters = await _getFavoriteCharacters();
      emit(FavoriteCharactersLoaded(characters: characters));
    }
  }

  bool getHasReachedMax({required int page, required CharacterInfo info}) => page >= info.count || info.next == null;

  Future<void> _saveToPreferences(CharacterInfo info) async {
    try {
      await _preferencesHelper.setCount(info.count);
      await _preferencesHelper.setPages(info.pages);

      if (info.next != null) {
        await _preferencesHelper.setNext(info.next!);
      }

      if (info.prev != null) {
        await _preferencesHelper.setPrev(info.prev!);
      }
    } catch (error, stack) {
      logger.e('''
       Error in CharacterBloc._saveToPreferences: 
       Error: $error,
       Stack: $stack,
       Parameters:
          info: $info
       ''');

      rethrow;
    }
  }

  Future<void> _writeCharacters(List<Character> characters) async {
    try {
      await _charactersService.writeCharacters(characters);
    } catch (error, stack) {
      logger.e('''
       Error in CharacterBloc._writeCharacters: 
       Error: $error,
       Stack: $stack,
       Parameters:
          characters: $characters
       ''');
      rethrow;
    }
  }

  Future<void> _updateCharacterFavorite({required int id, required bool isFavorite}) async {
    try {
      await _charactersService.changeFavorite(id: id, isFavorite: isFavorite);
    } catch (error, stack) {
      logger.e('''
       Error in CharacterBloc._updateCharacterFavorite: 
       Error: $error,
       Stack: $stack,
       Parameters:
          id: $id,
          isFavorite: $isFavorite
       ''');
      rethrow;
    }
  }
}

class CharactersError extends CharactersState {
  final String message;
  final List<Character> characters;
  final int currentPage;

  const CharactersError({required this.message, this.characters = const [], this.currentPage = 1});

  @override
  List<Object> get props => [message, characters, currentPage];
}
