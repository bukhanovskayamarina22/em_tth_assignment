import 'package:em_tth_assignment/data/models.dart';
import 'package:em_tth_assignment/utils/constants.dart';
import 'package:em_tth_assignment/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  Future<bool> getIsDark() async {
    final prefs = await _getPrefs();
    return prefs.getBool(KeysConstants.isDark) ?? false;
  }

  Future<void> setIsDark(bool isDark) async {
    final prefs = await _getPrefs();
    await prefs.setBool(KeysConstants.isDark, isDark);
  }

  Future<int?> getCount() async {
    final prefs = await _getPrefs();
    return prefs.getInt(KeysConstants.count);
  }

  Future<void> setCount(int count) async {
    final prefs = await _getPrefs();
    await prefs.setInt(KeysConstants.count, count);
  }

  Future<int?> getPages() async {
    final prefs = await _getPrefs();
    return prefs.getInt(KeysConstants.pages);
  }

  Future<void> setPages(int pages) async {
    final prefs = await _getPrefs();
    await prefs.setInt(KeysConstants.pages, pages);
  }

  Future<String?> getNext() async {
    final prefs = await _getPrefs();
    final string = prefs.getString(KeysConstants.next);
    return string.isNullOrEmpty ? null : string;
  }

  Future<void> setNext(String? next) async {
    final prefs = await _getPrefs();
    await prefs.setString(KeysConstants.next, next ?? '');
  }

  Future<String?> getPrev() async {
    final prefs = await _getPrefs();
    final string = prefs.getString(KeysConstants.prev);
    return string.isNullOrEmpty ? null : string;
  }

  Future<void> setPrev(String? prev) async {
    final prefs = await _getPrefs();
    await prefs.setString(KeysConstants.prev, prev ?? '');
  }

  Future<CharacterInfo> getInfo() async {
    final count = await getCount();
    final pages = await getPages();
    final next = await getNext();
    final prev = await getPrev();
    return CharacterInfo(count: count ?? 0, pages: pages ?? 0, next: next, prev: prev);
  }

  Future<void> clear() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
