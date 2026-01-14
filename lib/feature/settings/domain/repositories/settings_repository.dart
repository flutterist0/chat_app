abstract class SettingsRepository {
  Future<bool> getIsDarkMode();
  Future<void> setDarkMode(bool isDark);
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<String> getLanguageCode();
  Future<void> setLanguageCode(String languageCode);
}
