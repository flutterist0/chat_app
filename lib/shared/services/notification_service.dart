import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const String _channelId = 'chat_messages_channel';
  static const String _channelName = 'Chat Mesajları';

  static Future<void> initialize() async {
    await _requestNotificationPermission();

    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Bildirişə toxunuldu: ${response.payload}");
      },
    );

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Yeni chat mesajları üçün bildirişlər',
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Firebase İcazəsi
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Firebase icazəsi verildi');

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      _firebaseMessaging.onTokenRefresh.listen(_saveTokenToFirestore);
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Yeni mesaj: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('Android Notification Permission: $granted');
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
      print("✅ Token yazıldı: $token");
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Chat mesajları',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        enableLights: true,
        color: const Color(0xFF2563EB),
        ledColor: const Color(0xFF2563EB),
        ledOnMs: 1000,
        ledOffMs: 500,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        autoCancel: true,
        ongoing: false,
        ticker: '${message.notification?.title}: ${message.notification?.body}',
        // Expanded style
        styleInformation: BigTextStyleInformation(
          message.notification?.body ?? '',
          contentTitle: message.notification?.title,
          summaryText: 'Yeni mesaj',
        ),
        timeoutAfter: null,
        when: DateTime.now().millisecondsSinceEpoch,
        usesChronometer: false,
        chronometerCountDown: false,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        message.notification?.title ?? 'Yeni Mesaj',
        message.notification?.body ?? '',
        notificationDetails,
        payload: message.data.toString(),
      );

      print("✅ Bildiriş göstərildi ID: $id");
    } catch (e) {
      print("❌ Bildiriş xətası: $e");
    }
  }

  static Future<void> openNotificationSettings() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📱 Background mesaj: ${message.notification?.title}");
  await NotificationService.showNotification(message);
}