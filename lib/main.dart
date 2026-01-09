import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_app/feature/auth/presentation/auth_gate.dart';
import 'package:test_app/feature/auth/presentation/login_screen.dart';
import 'package:test_app/feature/chat/presentation/screens/chat_list_screen.dart';
import 'package:test_app/feature/notification/services/notification_service.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/shared/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/shared/routers/app_router.dart';
import 'package:test_app/feature/settings/logic/bloc/settings_bloc.dart';
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Arxa planda mesaj gəldi: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return MaterialApp.router(
                routerConfig: _appRouter.config(),
                title: 'Flutter Demo',
                themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData(
                  brightness: Brightness.light,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.light,
                  ),
                  scaffoldBackgroundColor: Colors.white,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  cardTheme: CardTheme(
                    color: Colors.white,
                    elevation: 2,
                  ),
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark,
                    surface: Colors.grey[900],
                    onSurface: Colors.white,
                  ),
                  scaffoldBackgroundColor: Colors.black,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  cardTheme: CardTheme(
                    color: Colors.grey[900],
                    elevation: 2,
                  ),
                  popupMenuTheme: PopupMenuThemeData(
                    color: Colors.grey[900],
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  dialogTheme: DialogTheme(
                    backgroundColor: Colors.grey[900],
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                    contentTextStyle: TextStyle(color: Colors.white70),
                  ),
                  useMaterial3: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
