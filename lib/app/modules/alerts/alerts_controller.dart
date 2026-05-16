import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AlertsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isPushEnabled = true.obs;
  var alerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToFirestoreAlerts();
    _setupPushNotifications();
  }

  void _listenToFirestoreAlerts() {
    String? uid = _auth.currentUser?.uid;

    _firestore
        .collection('users')
        .doc(uid)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      alerts.value = snapshot.docs.map((doc) {
        final data = doc.data();

        // ✅ Reconstruction du titre et message traduits côté Flutter
        final String zoneNum  = data['zone_num']  ?? '?';
        final double humidity = (data['humidity'] ?? 0.0).toDouble();
        final String type     = data['type']      ?? 'unknown';
        final String level    = data['level']     ?? 'warning';
        
        // Champs optionnels envoyés par le backend
        final String? rawTitle = data['title'];
        final String? rawMsg   = data['message'] ?? data['msg'] ?? data['body'];

        return {
          'id': doc.id,
          'title': _buildTitle(type, zoneNum, rawTitle),   
          'msg':   _buildMessage(type, humidity, rawMsg), 
          'level': level,
          'time':  _formatTimestamp(data['timestamp']),
        };
      }).toList();
    });
  }

  Future<void> deleteAlert(String alertId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || alertId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('alerts')
        .doc(alertId)
        .delete();
  }

  // ✅ Titre traduit selon le type et la zone
  String _buildTitle(String type, String zoneNum, String? rawTitle) {
    switch (type) {
      case 'prediction':
        return 'Anticipation RoboCare : Zone $zoneNum 🧠'; 
      case 'low_humidity':
        return '${'alert_zone'.tr} $zoneNum 🚨';
      case 'high_humidity':
        return '${'alert_zone'.tr} $zoneNum 💧';
      case 'ph_alert':
        return '${'alert_zone'.tr} $zoneNum ⚗️';
      case 'pump_reminder':
        return 'alert_pump_reminder_title'.tr;
      default:
        // ✅ Si le backend envoie un titre spécifique, on l'utilise
        if (rawTitle != null && rawTitle.isNotEmpty) return rawTitle;
        return '${'alert_zone'.tr} $zoneNum';
    }
  }

  // ✅ Message traduit avec la valeur injectée
  String _buildMessage(String type, double humidity, String? rawMsg) {
    switch (type) {
      case 'prediction':
        return 'alert_prediction'.trParams({
          'val': humidity.toStringAsFixed(1),
        });
      case 'low_humidity':
        return '${'alert_critical_humidity'.tr} ${humidity.toStringAsFixed(1)}%. ${'alert_pump_activated'.tr}';
      case 'high_humidity':
        return '${'alert_high_humidity'.tr} ${humidity.toStringAsFixed(1)}%. ${'alert_pump_stopped'.tr}';
      case 'ph_alert':
        return 'alert_ph_abnormal'.tr;
      default:
        // ✅ Priorité au message brut envoyé par le backend (pour les nouveaux types)
        if (rawMsg != null && rawMsg.isNotEmpty) return rawMsg;
        return 'alert_unknown'.tr;
    }
  }
  void _setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        Get.snackbar(
          message.notification!.title ?? 'alert'.tr,
          message.notification!.body  ?? '',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        );
      }
    });
  }

  void toggleNotifications(bool value) async {
    isPushEnabled.value = value;
    String? uid = _auth.currentUser?.uid;

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic("user_$uid");
      Get.snackbar(
        "notifications".tr,
        "notif_enabled".tr,   // ✅ clé traduite
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic("user_$uid");
      Get.snackbar(
        "notifications".tr,
        "notif_disabled".tr,  // ✅ clé traduite
        backgroundColor: Colors.grey,
        colorText: Colors.white,
      );
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "--:--";
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}