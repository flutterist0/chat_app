import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/service/auth_service.dart';
import 'package:test_app/feature/settings/logic/bloc/settings_bloc.dart';
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
          "Tənzimləmələr",
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
              _buildSectionTitle(context, "Bildirişlər"),
              SwitchListTile(
                title: Text(
                  "Bildirişləri al",
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
              _buildSectionTitle(context, "Görünüş"),
              SwitchListTile(
                title: Text("Qaranlıq rejim"),
                value: state.isDarkMode,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(ToggleTheme());
                },
                activeColor: AppStyles.primaryBlue,
                secondary: Icon(Icons.dark_mode_outlined, color: Colors.purple),
              ),
              Divider(color: Colors.grey.withOpacity(0.3)),
              _buildSectionTitle(context, "Hesab"),
              ListTile(
                leading: Icon(Icons.edit, color: AppStyles.primaryBlue),
                title: Text("Profilə düzəliş et"),
                onTap: () {
                  context.router.push(EditProfileRoute());
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text("Hesabı sil", style: TextStyle(color: Colors.red)),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
              Divider(color: Colors.grey.withOpacity(0.3)),
              _buildSectionTitle(context, "Tətbiq Haqqında"),
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.grey),
                title: Text("Versiya"),
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
              title: Text("Hesabı sil"),
              content: Text(
                  "Hesabınızı silmək istədiyinizə əminsiniz? Bu əməliyyat geri qaytarıla bilməz."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("Xeyr"),
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
                                "Xəta: Hesabı silmək üçün yenidən giriş etməlisiniz.")),
                      );
                      getIt<AuthService>().signOut();
                      context.router.replaceAll([LoginRoute()]);
                    }
                  },
                  child: Text("Bəli, sil", style: TextStyle(color: Colors.red)),
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
              title: Text("Kamera"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppStyles.primaryBlue),
              title: Text("Qalereya"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            if (context.read<SettingsBloc>().state.profileImageUrl != null)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Şəkli sil", style: TextStyle(color: Colors.red)),
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

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      context.read<SettingsBloc>().add(UpdateProfileImage(File(picked.path)));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil şəkli yenilənir...")),
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
}
