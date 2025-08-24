import 'package:bloc/bloc.dart';
import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/data/service.dart';
import 'package:em_tth_assignment/logic/event.dart';
import 'package:em_tth_assignment/logic/state.dart';

class CharacterBloc extends Bloc<CharactersEvent, CharactersState> {
  final ApiService _apiService;
  final PreferencesHelper _preferencesHelper;

  CharacterBloc({required ApiService apiService, required PreferencesHelper preferencesHelper})
    : _apiService = apiService,
      _preferencesHelper = preferencesHelper,
      super(const CharactersInitial()) {
    on<LoadAllCharacters>(_onLoadCharacters);
    on<LoadFavoriteCharacters>(_onLoadFavoriteCharacters);
    on<LoadNextPage>(_onLoadNextPage);
    on<RefreshCharacters>(_onRefreshCharacters);
  }

  Future<void> _onLoadCharacters(LoadAllCharacters event, Emitter<CharactersState> emit) async {
    emit(const CharactersLoading());
    await _fetchCharacters(emit, 1, []);
  }

  Future<void> _onLoadFavoriteCharacters(LoadFavoriteCharacters event, Emitter<CharactersState> emit) async {
    emit(
      //TODO: update those next and prev, read what they are supposed to do
      FavoriteCharactersLoaded(
        characters: const [],
        info: CharacterInfo(count: 1, pages: 1, next: 'asdf', prev: 'dfgh'),
        currentPage: 0,
        hasReachedMax: true,
      ),
    );
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

      final allCharacters = page == 1 ? response.results : [...existingCharacters, ...response.results];

      final maxPages = await _preferencesHelper.getCount() ?? 0;
      final hasReachedMax = page >= maxPages || response.info.next == null;

      emit(
        CharactersLoaded(
          characters: allCharacters,
          info: response.info,
          currentPage: page,
          hasReachedMax: hasReachedMax,
        ),
      );
    } catch (error) {
      emit(
        CharactersError(
          message: error.toString(),
          characters: existingCharacters,
          currentPage: page > 1 ? page - 1 : 1,
        ),
      );
    }
  }

  Future<void> _saveToPreferences(CharacterInfo info) async {
    await _preferencesHelper.setCount(info.count);
    await _preferencesHelper.setPages(info.pages);

    if (info.next != null) {
      await _preferencesHelper.setNext(info.next!);
    }

    if (info.prev != null) {
      await _preferencesHelper.setPrev(info.prev!);
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
