import 'package:get/get.dart';
import 'dart:async';
import 'package:intl/intl.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends GetxController {
  var soilMoisture = 45.obs;
  var temperature = 28.obs;
  var phValue = 6.4.obs;
  var batteryLevel = 80.obs;
  var isPumpOn = false.obs; 
  
  var currentDate = "".obs;
  var currentTime = "".obs;
  var humidityData = <FlSpot>[].obs;
  var temperatureData = <FlSpot>[].obs;
  var isDataLoaded = false.obs;

  StreamSubscription? _pumpSubscription;

  @override
  void onInit() {
    super.onInit();
    updateDateTime();
    loadInitialGraphData();
    initPumpSync(); 
    Timer.periodic(const Duration(minutes: 1), (timer) => updateDateTime());
  }

  void initPumpSync() {
    // Écoute directe du document Firebase
    _pumpSubscription = FirebaseFirestore.instance
        .collection('commands')
        .doc('variateur')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        isPumpOn.value = data['isOn'] ?? false;
        debugPrint("📡 Sync Firestore : Pompe = ${isPumpOn.value}");
      }
    });
  }

  void updateDateTime() {
    final now = DateTime.now();
    currentDate.value = DateFormat('dd MMMM yyyy').format(now); 
    currentTime.value = DateFormat('HH:mm').format(now);
  }

  void loadInitialGraphData() {
    humidityData.assignAll([const FlSpot(0, 50), const FlSpot(12, 38), const FlSpot(24, 50)]);
    temperatureData.assignAll([const FlSpot(0, 22), const FlSpot(12, 30), const FlSpot(24, 21)]);
    isDataLoaded.value = true;
  }

  @override
  void onClose() {
    _pumpSubscription?.cancel();
    super.onClose();
  }
}