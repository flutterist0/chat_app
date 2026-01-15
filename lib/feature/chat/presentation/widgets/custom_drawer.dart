import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/notification/presentation/screens/notification_screen.dart';
import 'package:test_app/l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              SizedBox(height: 20.h),
              // StreamBuilder for Counts
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return SizedBox.shrink();
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final followers = data?['followersCount'] ?? 0;
                  final following = data?['followingCount'] ?? 0;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                           Navigator.pop(context);
                           context.router.push(FollowersRoute(userId: FirebaseAuth.instance.currentUser!.uid));
                        },
                        child: Column(
                          children: [
                            Text(
                              '$followers',
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Followers', // Use AppLocalizations if available, or 'Takipçi'
                              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30.h, color: Colors.white24),
                      GestureDetector(
                        onTap: () {
                           Navigator.pop(context);
                           context.router.push(FollowingRoute(userId: FirebaseAuth.instance.currentUser!.uid));
                        },
                        child: Column(
                          children: [
                            Text(
                              '$following',
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Following', // 'Takip'
                              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20.h),
              Divider(color: Colors.white30, thickness: 1),
              _DrawerMenuItem(
                icon: Icons.manage_accounts_outlined,
                title: AppLocalizations.of(context)!.accounts,
                onTap: () {
                  Navigator.pop(context);
                  context.router.push(AccountCenterRoute());
                },
              ),
              _DrawerMenuItem(
                icon: Icons.settings_outlined,
                title: AppLocalizations.of(context)!.settingsTitle,
                onTap: () {
                  Navigator.pop(context);
                  context.router.push(SettingsRoute());
                },
              ),
              _DrawerMenuItem(
                icon: Icons.notifications_outlined,
                title: AppLocalizations.of(context)!.notificationsTitle,
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
                        AppLocalizations.of(context)!.logout,
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
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: logout,
            child: Text(AppLocalizations.of(context)!.yes, style: TextStyle(color: Colors.red)),
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
