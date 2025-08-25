import 'dart:math' as math;

import 'package:em_tth_assignment/data/characters_service.dart';
import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/data/service.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_bloc.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_event.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_state.dart';
import 'package:em_tth_assignment/logic/theme_bloc/theme_cubit.dart';
import 'package:em_tth_assignment/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final logger = Logger(printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart));
void main() async {
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (context) => ThemeCubit(PreferencesHelper()),
      child: BlocBuilder<ThemeCubit, Brightness>(
        builder: (context, state) {
          return MaterialApp(
            title: TextConstants.appName,
            theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: state)),

            home: MyHomePage(title: TextConstants.appName, theme: state),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, required this.theme, super.key});

  final String title;
  final Brightness theme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              final newTheme = isDark ? Brightness.light : Brightness.dark;
              context.read<ThemeCubit>().setTheme(newTheme);
            },
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
      //TODO: move out labels
      body: _selectedIndex == 0 ? const AllCharactersPage() : const FavoriteCharactersPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Characters'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class FavoriteCharactersPage extends StatelessWidget {
  const FavoriteCharactersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CharacterBloc(
            apiService: ApiService(),
            preferencesHelper: PreferencesHelper(),
            charactersService: CharactersService(),
          )..add(const LoadFavoriteCharacters()),
      child: const CharacterView(isFavorites: true),
    );
  }
}

class AllCharactersPage extends StatelessWidget {
  const AllCharactersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => CharacterBloc(
            apiService: ApiService(),
            preferencesHelper: PreferencesHelper(),
            charactersService: CharactersService(),
          )..add(const LoadAllCharacters()),
      child: const CharacterView(isFavorites: false),
    );
  }
}

class CharacterView extends StatelessWidget {
  const CharacterView({required this.isFavorites, super.key});
  final bool isFavorites;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Characters')),
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
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context.read<CharacterBloc>().add(const LoadAllCharacters()),
                    child: const Text('Retry'),
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

// TODO: split the file into widget files
class SliverLoadMore extends StatelessWidget {
  final bool hasReachedMax;
  final bool isLoadingMore;

  const SliverLoadMore({required this.hasReachedMax, required this.isLoadingMore, super.key});

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (hasReachedMax) {
      child = const Text('Nothing left');
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

//TODO: move out text to constants
class CharacterCard extends StatefulWidget {
  final Character character;
  final void Function(bool value) onFavoritePressed;

  const CharacterCard({required this.character, required this.onFavoritePressed, super.key});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  bool isFavorite = false;

  @override
  void initState() {
    isFavorite = widget.character.isFavorite;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: add explanation comments
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32) / 2;
    final scaleFactor = cardWidth / 180;
    final nameFontSize = (16 * scaleFactor).clamp(12.0, 20.0);
    final detailsFontSize = (12 * scaleFactor).clamp(10.0, 16.0);
    final iconSize = (20 * scaleFactor).clamp(16.0, 28.0);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(4 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox.expand(
                      child: Image.network(
                        widget.character.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.person, size: iconSize * 2, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: RotatingFavoriteButton(
                      isFavorite: isFavorite,
                      onFavoritePressed: () {
                        setState(() {
                          isFavorite = !widget.character.isFavorite;
                        });
                        widget.onFavoritePressed(!widget.character.isFavorite);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Text content
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.only(top: 4 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Character name
                    Text(
                      widget.character.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: nameFontSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Status
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: detailsFontSize),
                        children: [
                          const TextSpan(text: 'Status: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: widget.character.status),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Type
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(fontSize: detailsFontSize),
                        children: [
                          const TextSpan(text: 'Type: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(text: widget.character.type.isEmpty ? 'Unknown' : widget.character.type),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RotatingFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final void Function() onFavoritePressed;
  final double iconSize;

  const RotatingFavoriteButton({
    required this.isFavorite,
    required this.onFavoritePressed,
    super.key,
    this.iconSize = 24.0,
  });

  @override
  RotatingFavoriteButtonState createState() => RotatingFavoriteButtonState();
}

class RotatingFavoriteButtonState extends State<RotatingFavoriteButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    await _controller.forward();
    await _controller.forward();
    await _controller.reverse();
    await _controller.reverse();
    await _controller.forward();
    await _controller.reverse();
    widget.onFavoritePressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(angle: _rotationAnimation.value, child: child);
      },
      child: IconButton(
        onPressed: _onPressed,
        icon: Icon(Icons.star, color: widget.isFavorite ? Colors.yellow : Colors.grey),
        iconSize: widget.iconSize,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: widget.iconSize + 8, minHeight: widget.iconSize + 8),
      ),
    );
  }
}
