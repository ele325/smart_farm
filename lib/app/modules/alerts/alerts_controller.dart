import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlertsController extends GetxController {
  // Paramètres des Notifications
  var isPushEnabled = true.obs;

  // Configuration des Seuils (Exemple: Température max, Humidité min)
  var tempThreshold = 35.0.obs;
  var humidityThreshold = 20.0.obs;

  // Liste des alertes actives (Simulation)
  var activeAlerts = [
    {'title': 'Stress Hydrique', 'zone': 'Zone A', 'level': 'Critique', 'time': 'Il y a 10 min'},
    {'title': 'Batterie Faible', 'zone': 'Capteur 04', 'level': 'Avertissement', 'time': 'Il y a 1h'},
  ].obs;

  void toggleNotifications(bool value) => isPushEnabled.value = value;
  
  void updateThreshold(String type, double value) {
    if (type == 'temp') tempThreshold.value = value;
    if (type == 'hum') humidityThreshold.value = value;
  }
}