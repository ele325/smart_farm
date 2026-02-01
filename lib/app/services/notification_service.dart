import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Demander la permission (Android 13+ et iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialisation pour Android
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Logique quand on clique sur la notification (ex: aller à AlertsPage)
        print("Notification cliquée");
      },
    );

    // Création du canal pour Android (Importance max pour réveiller le téléphone)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'smartfarm_alerts',
      'Alertes Critiques SmartFarm',
      description: 'Ce canal est utilisé pour les alertes de stress hydrique.',
      importance: Importance.max,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Affiche la notification visuelle
  static void showNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _notificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'smartfarm_alerts',
          'Alertes SmartFarm',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}