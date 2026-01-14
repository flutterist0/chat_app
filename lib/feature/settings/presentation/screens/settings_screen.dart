import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';
import 'package:test_app/feature/settings/logic/bloc/settings_bloc.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/shared/themes/app_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';


@RoutePage()
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.all(16.sp),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.grey,
                      backgroundImage: _getProfileImageProvider(state.profileImageUrl),
                      child: _getProfileImageProvider(state.profileImageUrl) == null
                          ? Icon(Icons.person, size: 50.sp, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundColor: AppStyles.primaryBlue,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, color: Colors.white, size: 18.sp),
                          onPressed: () => _showImageSourceActionSheet(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle(context, AppLocalizations.of(context)!.notifications),
              SwitchListTile(
                title: Text(
                  AppLocalizations.of(context)!.receiveNotifications,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                value: state.notificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(ToggleNotifications());
                },
                activeColor: AppStyles.primaryBlue,
                secondary: Icon(Icons.notifications_outlined,
                    color: AppStyles.primaryBlue),
              ),
              Divider(color: Colors.grey.withOpacity(0.3)),
              _buildSectionTitle(context, AppLocalizations.of(context)!.appearance),
              SwitchListTile(
                title: Text(AppLocalizations.of(context)!.darkMode),
                value: state.isDarkMode,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(ToggleTheme());
                },
                activeColor: AppStyles.primaryBlue,
                secondary: Icon(Icons.dark_mode_outlined, color: Colors.purple),
              ),
              Divider(color: Colors.grey.withOpacity(0.3)),
               _buildSectionTitle(context, AppLocalizations.of(context)!.language),
              ListTile(
                leading: Icon(Icons.language, color: Colors.blue),
                title: Text(AppLocalizations.of(context)!.changeLanguage),
                trailing: Text(state.locale.languageCode.toUpperCase()),
                onTap: () => _showLanguageSourceActionSheet(context),
              ),
              Divider(color: Colors.grey.withOpacity(0.3)),
              _buildSectionTitle(context, AppLocalizations.of(context)!.account),
              ListTile(
                leading: Icon(Icons.edit, color: AppStyles.primaryBlue),
                title: Text(AppLocalizations.of(context)!.editProfile),
                onTap: () {
                  context.router.push(EditProfileRoute());
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.deleteAccount, style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
              Divider(color: Colors.grey.withOpacity(0.3)),
              _buildSectionTitle(context, AppLocalizations.of(context)!.aboutApp),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.grey),
                title: Text(AppLocalizations.of(context)!.version),
                trailing: Text("1.0.0"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.deleteAccountDialogTitle),
              content: Text(
                  AppLocalizations.of(context)!.deleteAccountDialogContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)!.no),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user
                            .delete();
                        context.router.replaceAll([LoginRoute()]);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                AppLocalizations.of(context)!.deleteAccountReauthError)),
                      );
                      getIt<AuthService>().signOut();
                      context.router.replaceAll([LoginRoute()]);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.yesDelete, style: TextStyle(color: Colors.red)),
                ),
              ],
            ));
  }
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppStyles.primaryBlue),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppStyles.primaryBlue),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            if (context.read<SettingsBloc>().state.profileImageUrl != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.removePhoto, style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<SettingsBloc>().add(DeleteProfileImage());
                },
              ),
          ],
        ),
      ),
    );
  }

  }

  void _showLanguageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text("Azərbaycan"),
              onTap: () {
                Navigator.pop(ctx);
                context.read<SettingsBloc>().add(ChangeLanguage('az'));
              },
            ),
            ListTile(
              title: Text("English"),
              onTap: () {
                Navigator.pop(ctx);
                context.read<SettingsBloc>().add(ChangeLanguage('en'));
              },
            ),
             ListTile(
              title: Text("Русский"),
              onTap: () {
                Navigator.pop(ctx);
                context.read<SettingsBloc>().add(ChangeLanguage('ru'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      context.read<SettingsBloc>().add(UpdateProfileImage(File(picked.path)));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profilePhotoUpdating)),
      );
    }
  }

  ImageProvider? _getProfileImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        return NetworkImage(url);
      }
    } catch (e) {
      debugPrint('Invalid image URL: $url error: $e');
    }
    return null;
  }
