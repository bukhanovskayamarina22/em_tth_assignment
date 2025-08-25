import 'package:em_tth_assignment/data/db/sqflite.dart';
import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/logic/theme_bloc/theme_cubit.dart';
import 'package:em_tth_assignment/ui/home_page.dart';
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
    return BlocProvider<ThemeCubit>(
      create: (context) => ThemeCubit(PreferencesHelper()),
      child: BlocBuilder<ThemeCubit, Brightness>(
        builder: (context, state) {
          return MaterialApp(
            title: TextConstants.appName,
            theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: state)),

            home: HomePage(title: TextConstants.appName, theme: state),
          );
        },
      ),
    );
  }
}
