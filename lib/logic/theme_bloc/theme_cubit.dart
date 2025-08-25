import 'package:em_tth_assignment/data/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//TODO: add error handling
class ThemeCubit extends Cubit<Brightness> {
  final PreferencesHelper _preferencesHelper;

  ThemeCubit(this._preferencesHelper) : super(Brightness.dark);

  Future<void> getTheme() async {
    final isDark = await _preferencesHelper.getIsDark();
    emit(isDark ? Brightness.dark : Brightness.light);
  }

  Future<void> setTheme(Brightness brightness) async {
    final isDark = brightness == Brightness.dark;
    await _preferencesHelper.setIsDark(isDark);
    emit(brightness);
  }
}
