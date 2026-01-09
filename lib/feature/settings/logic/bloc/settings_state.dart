part of 'settings_bloc.dart';

class SettingsState {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String? profileImageUrl;

  const SettingsState({
    required this.isDarkMode,
    required this.notificationsEnabled,
    this.profileImageUrl,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      isDarkMode: false, 
      notificationsEnabled: true,
      profileImageUrl: null,
    );
  }

  SettingsState copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? profileImageUrl,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
