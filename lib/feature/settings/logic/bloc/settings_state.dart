part of 'settings_bloc.dart';


class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String? profileImageUrl;
  final Locale locale;

  const SettingsState({
    required this.isDarkMode,
    required this.notificationsEnabled,
    this.profileImageUrl,
    required this.locale,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isDarkMode: false, 
      notificationsEnabled: true,
      profileImageUrl: null,
      locale: Locale('az'),
    );
  }

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? profileImageUrl,
    Locale? locale,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      locale: locale ?? this.locale,
    );
  }
}
