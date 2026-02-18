import 'package:get/get.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Données Capteur BGT-SMPS59 ---
  var soilMoisture = 0.0.obs;
  var temperature = 0.0.obs;
  var phValue = 6.5.obs;
  var ecValue = 0.0.obs; // Conductivité électrique
  var nitrogen = 0.0.obs; // N
  var phosphorus = 0.0.obs; // P
  var potassium = 0.0.obs; // K

  var isPumpOn = false.obs;
  var minHumidityThreshold = 30.0.obs;
  var currentDate = "".obs;
  var currentTime = "".obs;
  var isDataLoaded = false.obs;

  // Graphiques
  var humidityData = <FlSpot>[].obs;
  var temperatureData = <FlSpot>[].obs;

  StreamSubscription? _zoneSubscription;
  StreamSubscription? _configSubscription;
  StreamSubscription? _pumpSubscription;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _updateDateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateDateTime(),
    );
    loadInitialGraphData();
    initUserSync();
  }

  void initUserSync() {
    String? uid = _auth.currentUser?.uid;

    _zoneSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc('zone1')
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            var data = snap.data()!;
            soilMoisture.value = (data['humidity'] ?? 0.0).toDouble();
            temperature.value = (data['temperature'] ?? 0.0).toDouble();
            phValue.value = (data['ph'] ?? 0.0).toDouble();
            isPumpOn.value = data['isPumpOn'] ?? false;

            // Nouvelles valeurs du capteur
            ecValue.value = (data['ec'] ?? 0.0).toDouble();
            nitrogen.value = (data['azote'] ?? 0.0).toDouble();
            phosphorus.value = (data['phosphore'] ?? 0.0).toDouble();
            potassium.value = (data['potassium'] ?? 0.0).toDouble();

            isDataLoaded.value = true;
          }
        });

    _configSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('config')
        .doc('thresholds')
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            minHumidityThreshold.value = (snap.data()?['minHumidity'] ?? 30.0)
                .toDouble();
          }
        });

    _pumpSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('commands')
        .doc('variateur')
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            isPumpOn.value = snap.data()?['isOn'] ?? false;
          }
        });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    currentDate.value = DateFormat('EEE, d MMM yyyy', 'fr_FR').format(now);
    currentTime.value = DateFormat('HH:mm:ss').format(now);
  }

  void loadInitialGraphData() {
    humidityData.assignAll([
      const FlSpot(0, 45),
      const FlSpot(10, 35),
      const FlSpot(15, 50),
    ]);
    temperatureData.assignAll([
      const FlSpot(0, 20),
      const FlSpot(10, 25),
      const FlSpot(15, 23),
    ]);
  }

  @override
  void onClose() {
    _zoneSubscription?.cancel();
    _configSubscription?.cancel();
    _pumpSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
