import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../zones/zones_controller.dart';

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
  RxBool hasCustomThresholds = false.obs;

  // ✅ Ces observables lisent directement l'état du ZonesController (permanent)
  // Pas de timer local ici — le timer vit dans ZonesController
  RxBool get isIrrigating {
    final zone = _zonesController?.getZone(zoneId);
    return zone?.isIrrigating ?? false.obs;
  }

  RxInt get remainingSeconds {
    final zone = _zonesController?.getZone(zoneId);
    return zone?.remainingSeconds ?? 0.obs;
  }

  ZonesController? get _zonesController {
    if (Get.isRegistered<ZonesController>()) {
      return Get.find<ZonesController>();
    }
    return null;
  }

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
    // ✅ NE PAS annuler le timer ici — il vit dans ZonesController
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
  }

  // ✅ Les méthodes de modification ont été supprimées car seuls les ingénieurs 
  // configurent les seuils via l'interface d'administration ou directement en base.


  /// ✅ Délègue le démarrage du timer au ZonesController (permanent)
  Future<void> startTimedIrrigation() async {
    final zonesCtrl = _zonesController;
    if (zonesCtrl == null) {
      debugPrint("❌ [THRESHOLDS] ZonesController introuvable !");
      return;
    }

    final zone = zonesCtrl.getZone(zoneId);
    if (zone != null && zone.isIrrigating.value) {
      debugPrint("⚠️ [THRESHOLDS] Arrosage déjà en cours pour $zoneId");
      return;
    }

    final int totalSeconds = duration.value * 60;

    await zonesCtrl.startTimedIrrigation(
      zoneId: zoneId,
      zoneName: zoneName,
      totalSeconds: totalSeconds,
    );
  }

  /// ✅ Arrêt immédiat
  Future<void> stopTimedIrrigation() async {
    final zonesCtrl = _zonesController;
    if (zonesCtrl == null) return;
    await zonesCtrl.stopTimedIrrigation(zoneId);
  }
}