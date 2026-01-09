import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test_app/feature/settings/domain/repositories/settings_repository.dart';

import 'package:test_app/feature/auth/domain/repositories/auth_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  final AuthRepository _authRepository;

  SettingsBloc(this._settingsRepository, this._authRepository) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ToggleNotifications>(_onToggleNotifications);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<DeleteProfileImage>(_onDeleteProfileImage);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    final isDark = await _settingsRepository.getIsDarkMode();
    final notifications = await _settingsRepository.getNotificationsEnabled();
    final user = _authRepository.currentUser;
    emit(state.copyWith(
      isDarkMode: isDark, 
      notificationsEnabled: notifications,
      profileImageUrl: user?.photoURL,
    ));
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) async {
    final newMode = !state.isDarkMode;
    await _settingsRepository.setDarkMode(newMode);
    emit(state.copyWith(isDarkMode: newMode));
  }

  Future<void> _onToggleNotifications(ToggleNotifications event, Emitter<SettingsState> emit) async {
    final newStatus = !state.notificationsEnabled;
    await _settingsRepository.setNotificationsEnabled(newStatus);
    emit(state.copyWith(notificationsEnabled: newStatus));
  }

  Future<void> _onUpdateProfileImage(UpdateProfileImage event, Emitter<SettingsState> emit) async {
    try {
      final downloadUrl = await _authRepository.uploadProfileImage(event.image);
      emit(state.copyWith(profileImageUrl: downloadUrl));
    } catch (e) {
      print("Profile upload error: $e");
    }
  }

  Future<void> _onDeleteProfileImage(DeleteProfileImage event, Emitter<SettingsState> emit) async {
    try {
      await _authRepository.deleteProfileImage();
      emit(SettingsState(
        isDarkMode: state.isDarkMode,
        notificationsEnabled: state.notificationsEnabled,
        profileImageUrl: null,
      ));
    } catch (e) {
      print("Profile delete error: $e");
    }
  }
}
