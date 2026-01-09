part of 'settings_bloc.dart';

@immutable
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {}

class ToggleNotifications extends SettingsEvent {}

class UpdateProfileImage extends SettingsEvent {
  final dynamic image;
  UpdateProfileImage(this.image);
}

class DeleteProfileImage extends SettingsEvent {}
