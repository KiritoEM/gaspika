// ignore_for_file: strict_top_level_inference

import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gaspika_mobile/configs/app_router.dart';
import 'package:gaspika_mobile/firebase_options.dart';

@pragma('vm:entry-point')
void onLocalNotificationTap(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null) return;

  final data = jsonDecode(payload) as Map<String, dynamic>;
  final routeName = data['route'] as String?;
  if (routeName == null) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppRouter.router.go(routeName);
  });
}

@pragma('vm:entry-point')
void onLocalNotificationBackground(NotificationResponse response) {
  debugPrint("Background tap: ${response.payload}");
}

class NotificationService {
  //
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final _messaging;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications importantes',
    description: 'Canal pour les notifications FCM',
    importance: .high,
  );

  Future init() async {
    //init firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _messaging = FirebaseMessaging.instance;

    // create android channel
    _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    //init local notifications config
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onLocalNotificationBackground,      
    );

    // ios permission request
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // ios foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // request permission
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // foreground notifications handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        "Foreground message: ${message.messageId} | message: ${message.data}",
      );

      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: "@mipmap/ic_launcher",
            importance: .high,
            priority: .high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });

    // handle background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigate(message.data);
    });

    //launch app from a notification (terminated state)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNavigate(initial.data);
      });
    }

    // refresh token
    _messaging.onTokenRefresh.listen((newToken) {
      getFCMToken();
    });
  }

  // navigate to specific screen based on notification data
  void _handleNavigate(Map<String, dynamic> data) {
    final routeName = data['route'] as String?;

    debugPrint("Handling navigation for route: $routeName with data: $data");

    if (routeName == null) return;

    debugPrint("Navigating to route: $routeName");

    AppRouter.router.go(routeName);
  }

  // get FCM token and send it to backend
  Future<String?> getFCMToken() async {
    if (Platform.isIOS) {
      final apns = await _messaging.getAPNSToken();

      if (apns == null) {
        await Future.delayed(Duration(seconds: 2));
      }
    }

    final token = await _messaging.getToken();

    if (token == null) return null;

    return token;
  }
}
