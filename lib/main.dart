import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/presentation/auth_gate.dart';
import 'package:test_app/feature/auth/presentation/login_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_list_screen.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/shared/services/notification_service.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Arxa planda mesaj gəldi: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
           designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: _appRouter.config(),
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      );
      },
      child: AuthGate()
    );
  }
}
