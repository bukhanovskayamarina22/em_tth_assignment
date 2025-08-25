import 'package:em_tth_assignment/data/preferences.dart';
import 'package:em_tth_assignment/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<Brightness> {
  final PreferencesHelper _preferencesHelper;

  ThemeCubit(this._preferencesHelper) : super(Brightness.dark);

  Future<void> getTheme() async {
    try {
      final isDark = await _preferencesHelper.getIsDark();
      emit(isDark ? Brightness.dark : Brightness.light);
    } catch (error, stack) {
      logger.e('''
       Error in ThemeCubit.getTheme: 
       Error: $error,
       Stack: $stack
    ''');
      rethrow;
    }
  }

  Future<void> setTheme(Brightness brightness) async {
    try {
      final isDark = brightness == Brightness.dark;
      await _preferencesHelper.setIsDark(isDark);
      emit(brightness);
    } catch (error, stack) {
      logger.e('''
       Error in ThemeCubit.setTheme: 
       Error: $error,
       Stack: $stack,
       Parameters:
          brightness: $brightness
    ''');
      rethrow;
    }
  }
}
