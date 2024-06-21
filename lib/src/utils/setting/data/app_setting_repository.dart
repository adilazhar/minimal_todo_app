import 'package:minimal_todo_app/src/utils/setting/data/shared_preferences_provider.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting.dart';
import 'package:minimal_todo_app/src/utils/setting/domain/app_setting_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_setting_repository.g.dart';

class AppSettingRepository {
  final SharedPreferences _prefs;

  AppSettingRepository(this._prefs);

  Future<AppSetting> loadSettings() async {
    bool? isDarkMode = _prefs.getBool(AppSettingHelper.isDarkMode);
    return AppSetting(isDarkMode: isDarkMode);
  }

  Future<void> saveData(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw Exception(
          'Invalid data type. SharedPreferences can only store bool, int, double, String, and List<String>.');
    }
  }
}

@Riverpod(keepAlive: true)
FutureOr<AppSettingRepository> appSettingRepository(
    AppSettingRepositoryRef ref) async {
  final pref = await ref.watch(sharedPreferencesProvider.future);
  return AppSettingRepository(pref);
}
