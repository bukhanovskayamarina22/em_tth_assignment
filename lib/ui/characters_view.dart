import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_bloc.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_event.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_state.dart';
import 'package:em_tth_assignment/ui/character_card.dart';
import 'package:em_tth_assignment/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterView extends StatelessWidget {
  const CharacterView({required this.isFavorites, super.key});
  final bool isFavorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(TextConstants.characters)),
      body: BlocBuilder<CharacterBloc, CharactersState>(
        builder: (context, state) {
          if (state is CharactersInitial || state is CharactersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CharactersError && state.characters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${TextConstants.error}${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<CharacterBloc>().add(const LoadAllCharacters()),
                    child: const Text(TextConstants.retry),
                  ),
                ],
              ),
            );
          }

          List<Character> characters;
          if (state is CharactersLoaded && isFavorites == false) {
            characters = state.characters;
          } else if (state is FavoriteCharactersLoaded && isFavorites == true) {
            characters = state.characters;
          } else if (state is CharactersLoadingMore) {
            characters = state.characters;
          } else if (state is CharactersError) {
            characters = state.characters;
          } else {
            characters = <Character>[];
          }

          final isLoadingMore = state is CharactersLoadingMore;
          final hasReachedMax = state is CharactersLoaded ? state.hasReachedMax : false;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CharacterBloc>().add(const RefreshCharacters());
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      return CharacterCard(
                        key: UniqueKey(),
                        character: character,
                        onFavoritePressed: (value) {
                          context.read<CharacterBloc>().add(
                            ChangeCharacterFavorite(id: character.id, isFavorite: value),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (!isFavorites) SliverLoadMore(hasReachedMax: hasReachedMax, isLoadingMore: isLoadingMore),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SliverLoadMore extends StatelessWidget {
  final bool hasReachedMax;
  final bool isLoadingMore;

  const SliverLoadMore({required this.hasReachedMax, required this.isLoadingMore, super.key});

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (hasReachedMax) {
      child = const Text(TextConstants.nothingLeft);
    } else if (isLoadingMore) {
      child = const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    } else {
      child = Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            context.read<CharacterBloc>().add(const LoadNextPage());
          },
          child: const Text(TextConstants.loadMore),
        ),
      );
    }

    return SliverToBoxAdapter(child: child);
  }
}
