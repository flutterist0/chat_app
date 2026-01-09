import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/feature/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyNotifications = 'notifications_enabled';

  SettingsRepositoryImpl(this._prefs);

  @override
  Future<bool> getIsDarkMode() async {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(_keyDarkMode, isDark);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    return _prefs.getBool(_keyNotifications) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotifications, enabled);
  }
}
