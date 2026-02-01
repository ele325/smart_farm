import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AlertsController extends GetxController {
  var isPushEnabled = true.obs;

  // Liste réactive des alertes
  var alerts = <Map<String, String>>[
    {
      'title': 'crit_hydric_stress'.tr,
      'msg': 'zone_north_low_hum'.tr,
      'level': 'critique',
      'time': '10:45'
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Écoute les messages Firebase pendant que l'app est ouverte
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        addAlert(
          message.notification!.title ?? "Alerte",
          message.notification!.body ?? "",
          "critique", // On peut passer le niveau via les 'data' de Firebase
        );
      }
    });
  }

  void toggleNotifications(bool value) async {
    isPushEnabled.value = value;
    if (value) {
      // Abonne l'utilisateur au topic pour recevoir les alertes groupées
      await FirebaseMessaging.instance.subscribeToTopic("alerts");
      Get.snackbar("Notifications", "Activées pour le topic 'alerts'");
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic("alerts");
      Get.snackbar("Notifications", "Désactivées");
    }
  }

  void addAlert(String title, String msg, String level) {
    // Formatage de l'heure propre (HH:mm)
    String formattedTime = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    
    alerts.insert(0, {
      'title': title,
      'msg': msg,
      'level': level,
      'time': formattedTime
    });
  }
}