import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AlertsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  var isPushEnabled = true.obs;
  
  // Liste réactive des alertes provenant de Firestore
  var alerts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToFirestoreAlerts();
    _setupPushNotifications();
  }

  // --- ÉCOUTE FIRESTORE (users/UID/alerts) ---
  void _listenToFirestoreAlerts() {
    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      _firestore
          .collection('users')
          .doc(uid)
          .collection('alerts')
          .orderBy('timestamp', descending: true) // Les plus récentes en premier
          .snapshots()
          .listen((snapshot) {
        alerts.value = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'title': data['title'] ?? 'Alerte',
            'msg': data['message'] ?? '',
            'level': data['level'] ?? 'warning',
            'time': _formatTimestamp(data['timestamp']),
          };
        }).toList();
      });
    }
  }

  // --- CONFIGURATION PUSH NOTIFICATIONS ---
  void _setupPushNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Optionnel : On peut aussi ajouter l'alerte manuellement ici 
        // si elle n'est pas encore enregistrée dans Firestore
        Get.snackbar(
          message.notification!.title!,
          message.notification!.body!,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    });
  }

  void toggleNotifications(bool value) async {
    isPushEnabled.value = value;
    String? uid = _auth.currentUser?.uid;
    
    if (value && uid != null) {
      // S'abonner à un topic spécifique à l'utilisateur pour la sécurité
      await FirebaseMessaging.instance.subscribeToTopic("user_$uid");
      Get.snackbar("Notifications".tr, "Activées".tr);
    } else if (uid != null) {
      await FirebaseMessaging.instance.unsubscribeFromTopic("user_$uid");
      Get.snackbar("Notifications".tr, "Désactivées".tr);
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "--:--";
    DateTime date = (timestamp as Timestamp).toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}