import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/data/service.dart';
import 'package:em_tth_assignment/data/sqflite.dart';
import 'package:em_tth_assignment/logic/bloc.dart';
import 'package:em_tth_assignment/logic/event.dart';
import 'package:em_tth_assignment/logic/state.dart';
import 'package:em_tth_assignment/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final logger = Logger(printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart));
void main() async {
  databaseFactory = databaseFactoryFfi;
  await DatabaseHelper().delete();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: TextConstants.appName,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
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
          (context) =>
              CharacterBloc(apiService: ApiService(), preferencesHelper: PreferencesHelper())
                ..add(const LoadFavoriteCharacters()),
      child: const CharacterView(isFavorite: true),
    );
  }
}

class AllCharactersPage extends StatelessWidget {
  const AllCharactersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              CharacterBloc(apiService: ApiService(), preferencesHelper: PreferencesHelper())
                ..add(const LoadAllCharacters()),
      child: const CharacterView(isFavorite: false),
    );
  }
}

class CharacterView extends StatelessWidget {
  const CharacterView({required this.isFavorite, super.key});
  final bool isFavorite;

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
          if (state is CharactersLoaded && isFavorite == false) {
            characters = state.characters;
          } else if (state is FavoriteCharactersLoaded && isFavorite == true) {
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
                      // TODO: update favorite in database
                      return CharacterCard(character: character, onFavoritePressed: (value) {});
                    },
                  ),
                ),
                SliverLoadMore(hasReachedMax: hasReachedMax, isLoadingMore: isLoadingMore),
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
      child = const SizedBox.shrink();
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
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                        widget.onFavoritePressed(isFavorite);
                      },
                      icon: Icon(Icons.star, color: isFavorite ? Colors.yellow : Colors.grey),
                      iconSize: iconSize,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: iconSize + 8, minHeight: iconSize + 8),
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
