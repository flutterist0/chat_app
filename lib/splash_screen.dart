import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/shared/themes/app_styles.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (user != null) {
        context.router.replace(  ChatsListRoute());
      } else {
        context.router.replace(const LoginRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: AppStyles.circleGradientDecoration,
              child: Icon(
                Icons.chat_bubble_rounded,
                size: 50.sp,
                color: AppStyles.white,
              ),
            ),
            SizedBox(height: 20.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}