import 'package:get/get.dart';
import 'dart:async';
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardController extends GetxController {
  // --- VARIABLES CAPTEURS ---
  var soilMoisture = 45.obs;
  var temperature = 28.obs;
  var phValue = 6.4.obs;
  var batteryLevel = 80.obs;
  var isPumpOn = false.obs;
  
  // --- VARIABLES TEMPS ---
  var currentDate = "".obs;
  var currentTime = "".obs;

  // --- VARIABLES GRAPHIQUE ---
  var humidityData = <FlSpot>[].obs;
  var temperatureData = <FlSpot>[].obs;
  var isDataLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    updateDateTime();
    loadInitialGraphData();
    // Mise à jour automatique de l'heure
    Timer.periodic(const Duration(minutes: 1), (timer) => updateDateTime());
  }

  void updateDateTime() {
    try {
      final now = DateTime.now();
      currentDate.value = DateFormat('dd MMMM yyyy', 'fr_FR').format(now);
      currentTime.value = DateFormat('HH:mm').format(now);
    } catch (e) {
      currentDate.value = "Date non disponible";
    }
  }

  void loadInitialGraphData() {
    // Données pour tracer les deux courbes
    humidityData.assignAll([
      const FlSpot(0, 50),
      const FlSpot(6, 45),
      const FlSpot(12, 38),
      const FlSpot(18, 55),
      const FlSpot(24, 50),
    ]);

    temperatureData.assignAll([
      const FlSpot(0, 22),
      const FlSpot(6, 21),
      const FlSpot(12, 30),
      const FlSpot(18, 26),
      const FlSpot(24, 21),
    ]);

    isDataLoaded.value = true;
  }

  // Fonction pour le bouton Pump du Quick Access
  void togglePump() {
    isPumpOn.value = !isPumpOn.value;
    debugPrint("Pompe passée à : ${isPumpOn.value}");
  }

  // Fonction rafraîchir (Refresh Button)
  Future<void> fetchSensorData() async {
    soilMoisture.value = 40 + (DateTime.now().second % 15);
    temperature.value = 25 + (DateTime.now().second % 10);
    phValue.value = 6.0 + (DateTime.now().second % 10) / 10;
    
    // Simuler une petite variation de batterie
    if (batteryLevel.value > 5) batteryLevel.value -= 1;

    updateDateTime();
  }
}