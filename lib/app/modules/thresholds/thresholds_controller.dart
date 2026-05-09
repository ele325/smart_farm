import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThresholdRangeData {
  double min;
  double max;

  ThresholdRangeData({required this.min, required this.max});

  factory ThresholdRangeData.fromMap(
    Map<String, dynamic>? data, {
    required double defaultMin,
    required double defaultMax,
  }) {
    return ThresholdRangeData(
      min: (data?['min'] ?? defaultMin).toDouble(),
      max: (data?['max'] ?? defaultMax).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {'min': min, 'max': max};
}

class ThresholdsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String zoneId;
  final String zoneName;

  ThresholdsController({required this.zoneId, required this.zoneName});

  RxString plantType = ''.obs;
  RxDouble minHumidity = 30.0.obs;
  RxDouble maxHumidity = 70.0.obs;
  RxInt duration = 15.obs;
  final TextEditingController durationController = TextEditingController(text: '15');
  RxBool isLoading = false.obs;
  RxBool isIrrigating = false.obs; // ✅ État local de l'arrosage
  RxInt remainingSeconds = 0.obs;  // ✅ Compte à rebours visible
  RxBool hasCustomThresholds = false.obs;
  Timer? _irrigationTimer;         // ✅ Timer côté Flutter

  RxMap<String, ThresholdRangeData> thresholds = <String, ThresholdRangeData>{
    'humidity': ThresholdRangeData(min: 30, max: 70),
    'temperature': ThresholdRangeData(min: 18, max: 30),
    'ph': ThresholdRangeData(min: 5.5, max: 7.5),
    'ec': ThresholdRangeData(min: 150, max: 200),
    'n': ThresholdRangeData(min: 20, max: 40),
    'p': ThresholdRangeData(min: 15, max: 30),
    'k': ThresholdRangeData(min: 20, max: 35),
  }.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToSettings();
  }

  @override
  void onClose() {
    _irrigationTimer?.cancel();
    durationController.dispose();
    super.onClose();
  }

  void _listenToSettings() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null || zoneId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .collection('plante')
        .doc('current')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            Map<String, dynamic> data = snapshot.data()!;
            plantType.value = (data['plant_type'] ?? '').toString();

            final rawThresholds = data['thresholds'] as Map<String, dynamic>?;
            hasCustomThresholds.value =
                rawThresholds != null && rawThresholds.isNotEmpty;
            if (!hasCustomThresholds.value) return;

            thresholds['humidity'] = ThresholdRangeData.fromMap(
              rawThresholds?['humidity'] as Map<String, dynamic>?,
              defaultMin: 30,
              defaultMax: 70,
            );
            thresholds['temperature'] = ThresholdRangeData.fromMap(
              rawThresholds?['temperature'] as Map<String, dynamic>?,
              defaultMin: 18,
              defaultMax: 30,
            );
            thresholds['ph'] = ThresholdRangeData.fromMap(
              rawThresholds?['ph'] as Map<String, dynamic>?,
              defaultMin: 5.5,
              defaultMax: 7.5,
            );
            thresholds['ec'] = ThresholdRangeData.fromMap(
              rawThresholds?['ec'] as Map<String, dynamic>?,
              defaultMin: 150,
              defaultMax: 200,
            );
            thresholds['n'] = ThresholdRangeData.fromMap(
              rawThresholds?['n'] as Map<String, dynamic>?,
              defaultMin: 20,
              defaultMax: 40,
            );
            thresholds['p'] = ThresholdRangeData.fromMap(
              rawThresholds?['p'] as Map<String, dynamic>?,
              defaultMin: 15,
              defaultMax: 30,
            );
            thresholds['k'] = ThresholdRangeData.fromMap(
              rawThresholds?['k'] as Map<String, dynamic>?,
              defaultMin: 20,
              defaultMax: 35,
            );

            minHumidity.value = thresholds['humidity']!.min;
            maxHumidity.value = thresholds['humidity']!.max;
          } else {
            plantType.value = zoneName;
            hasCustomThresholds.value = false;
          }
        });

    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .collection('config')
        .doc('thresholds')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            int val = (data['duration'] ?? 15).toInt();
            duration.value = val;
            durationController.text = val.toString();
          }
        });

    // ✅ Écouter l'état de la zone pour synchroniser isIrrigating
    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data()!;
            final enabled = data['enabled'] ?? false;
            // Si Firestore dit OFF et qu'on irrigue → stopper le timer
            if (!enabled && isIrrigating.value) {
              _cancelTimer();
            }
          }
        });
  }

  void setThresholdMin(String key, double value) {
    final current = thresholds[key];
    if (current == null) return;
    if (value <= current.max) {
      thresholds[key] = ThresholdRangeData(min: value, max: current.max);
      if (key == 'humidity') minHumidity.value = value;
    }
  }

  void setThresholdMax(String key, double value) {
    final current = thresholds[key];
    if (current == null) return;
    if (value >= current.min) {
      thresholds[key] = ThresholdRangeData(min: current.min, max: value);
      if (key == 'humidity') maxHumidity.value = value;
    }
  }

  Future<bool> saveSettings() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null || zoneId.isEmpty) return false;
    if (!hasCustomThresholds.value) {
      Get.snackbar(
        "Information",
        "Aucun seuil réel n'est configuré par l'admin pour cette zone.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    try {
      isLoading.value = true;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .collection('plante')
          .doc('current')
          .set({
            'plant_type': plantType.value.isEmpty ? zoneName : plantType.value,
            'thresholds': {
              'humidity': thresholds['humidity']!.toMap(),
              'temperature': thresholds['temperature']!.toMap(),
              'ph': thresholds['ph']!.toMap(),
              'ec': thresholds['ec']!.toMap(),
              'n': thresholds['n']!.toMap(),
              'p': thresholds['p']!.toMap(),
              'k': thresholds['k']!.toMap(),
            },
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .collection('config')
          .doc('thresholds')
          .set({
            'minHumidity': thresholds['humidity']!.min,
            'maxHumidity': thresholds['humidity']!.max,
            'duration': duration.value,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      hasCustomThresholds.value = true;
      return true;
    } catch (e) {
      debugPrint("Erreur Firebase: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startTimedIrrigation() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null || zoneId.isEmpty) return;
    if (isIrrigating.value) return; // Déjà en cours

    final int minutes = duration.value;
    final int totalSeconds = minutes * 60;

    try {
      isLoading.value = true;

      // ✅ 1. Écrire la commande pour l'ESP32 via le Bridge
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .update({
        'timed_order_seconds': totalSeconds,
        'enabled': true,
        'irrigation_status': 'STARTED',
      });

      // ✅ 2. Démarrer le timer côté Flutter
      isIrrigating.value = true;
      remainingSeconds.value = totalSeconds;

      _irrigationTimer?.cancel();
      _irrigationTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        remainingSeconds.value--;
        if (remainingSeconds.value <= 0) {
          await _finishIrrigation(uid);
        }
      });

      Get.snackbar(
        "💧 Irrigation lancée",
        "Arrosage de $minutes min en cours pour $zoneName",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1B5E20),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint("Erreur lancement irrigation: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Appelé automatiquement à la fin du timer
  Future<void> _finishIrrigation(String uid) async {
    _irrigationTimer?.cancel();
    _irrigationTimer = null;
    isIrrigating.value = false;
    remainingSeconds.value = 0;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .update({
        'enabled': false,
        'irrigation_status': 'FINISHED',
      });

      debugPrint("✅ [THRESHOLDS] Irrigation terminée pour $zoneId");

      Get.snackbar(
        "✅ Irrigation Terminée",
        "L'arrosage de $zoneName est fini. La pompe est fermée.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint("Erreur fin irrigation: $e");
    }
  }

  void _cancelTimer() {
    _irrigationTimer?.cancel();
    _irrigationTimer = null;
    isIrrigating.value = false;
    remainingSeconds.value = 0;
  }
}