import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  RxBool isLoading = false.obs;
  RxBool hasCustomThresholds = false.obs;
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
            duration.value = (data['duration'] ?? 15).toInt();
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
}