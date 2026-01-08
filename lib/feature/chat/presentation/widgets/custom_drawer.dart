import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/notification/presentation/screens/notification_screen.dart';
import 'package:test_app/shared/routers/app_router.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userImageUrl;
final VoidCallback logout;
  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userImageUrl, required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.white24,
                ),
                child: userImageUrl != null
                    ? ClipOval(
                  child: Image.network(
                    userImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 50.sp,
                        color: Colors.white,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 50.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                userEmail,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 40.h),
              Divider(color: Colors.white30, thickness: 1),
              _DrawerMenuItem(
                icon: Icons.person_outline,
                title: 'Profil',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _DrawerMenuItem(
                icon: Icons.settings_outlined,
                title: 'Tənzimləmələr',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _DrawerMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Bildirişlər',
                onTap: () {
                  Navigator.pop(context); 
                  context.router.navigate(NotificationRoute());
                },
              ),
              Divider(color: Colors.white30, thickness: 1),
              Spacer(),
              Padding(
                padding: EdgeInsets.all(16.sp),
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Color(0xFF2563EB),
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Çıxış',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Çıxış'),
        content: Text('Hesabdan çıxmaq istədiyinizə əminsiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Xeyr'),
          ),
          TextButton(
            onPressed: logout,
            child: Text('Bəli', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 26.sp),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
