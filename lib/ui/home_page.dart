import 'package:em_tth_assignment/data/db/characters_service.dart';
import 'package:em_tth_assignment/data/http/api_service.dart';
import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_bloc.dart';
import 'package:em_tth_assignment/logic/characters_bloc/characters_event.dart';
import 'package:em_tth_assignment/logic/theme_bloc/theme_cubit.dart';
import 'package:em_tth_assignment/ui/characters_view.dart';
import 'package:em_tth_assignment/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.title, required this.theme, super.key});

  final String title;
  final Brightness theme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: _selectedIndex == 0 ? const AllCharactersPage() : const FavoriteCharactersPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: TextConstants.characters),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: TextConstants.favorites),
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
