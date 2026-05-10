import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Zone {
  final String id;
  final String name;
  final String zoneNum;
  RxString plantType;
  RxBool enabled;
  RxString irrigationStatus;
  RxInt selectedDuration; // En secondes
  RxBool isIrrigating;   // ✅ État local persistant
  RxInt remainingSeconds; // ✅ Compte à rebours visible depuis n'importe quelle page

  RxDouble humidity;
  RxDouble temperature;
  RxDouble ph;
  RxDouble ec;
  RxDouble azote;
  RxDouble phosphore;
  RxDouble potassium;
  RxInt sante;

  Zone({
    required this.id,
    required this.name,
    required this.zoneNum,
    required String plantType,
    required bool status,
    required String irrigationStatus,
    required double humidity,
    required double temperature,
    required double ph,
    required double ec,
    required double azote,
    required double phosphore,
    required double potassium,
    required int sante,
  }) : plantType = plantType.obs,
       enabled = status.obs,
       irrigationStatus = irrigationStatus.obs,
       selectedDuration = 60.obs, // 1 min par défaut
       isIrrigating = false.obs,
       remainingSeconds = 0.obs,
       humidity = humidity.obs,
       temperature = temperature.obs,
       ph = ph.obs,
       ec = ec.obs,
       azote = azote.obs,
       phosphore = phosphore.obs,
       potassium = potassium.obs,
       sante = sante.obs;
}

class ZonesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxList<Zone> zones = <Zone>[].obs;
  StreamSubscription? _subscription;

  // ✅ Map de timers persistants : un timer par zone
  final Map<String, Timer> _irrigationTimers = {};

  @override
  void onInit() {
    super.onInit();
    zones.clear();
    _ecouterLesZones();
    _startSafetyTimer();
  }

  Timer? _safetyTimer;
  void _startSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return;
      
      // On vérifie manuellement chaque zone active localement
      for (var zone in zones) {
        if (zone.enabled.value && zone.irrigationStatus.value == 'STARTED') {
          // Note: On n'a pas les données brutes Firestore ici, 
          // mais le listener s'en chargera via _checkAndResumeTimer.
          // Ce timer force une vérification de l'UI.
        }
      }
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _safetyTimer?.cancel();
    for (final t in _irrigationTimers.values) {
      t.cancel();
    }
    _irrigationTimers.clear();
    super.onClose();
  }

  void _ecouterLesZones() {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint("❌ [ZONES] Utilisateur non connecté");
      return;
    }

    _subscription?.cancel();

    _subscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .snapshots()
        .listen(
          (snapshot) async {
            for (final doc in snapshot.docs) {
              final d = doc.data();

              final existingIndex = zones.indexWhere((z) => z.id == doc.id);

              String plantType = (d['plant_type'] ?? '').toString();
              final plantSnap = await doc.reference
                  .collection('plante')
                  .doc('current')
                  .get();
              if (plantSnap.exists) {
                plantType = (plantSnap.data()?['plant_type'] ?? plantType).toString();
              }

              if (existingIndex >= 0) {
                final zone = zones[existingIndex];
                zone.plantType.value = plantType;
                zone.enabled.value = d['enabled'] ?? false;
                zone.irrigationStatus.value = d['irrigation_status'] ?? 'IDLE';
                zone.humidity.value = (d['humidity'] ?? 0.0).toDouble();
                zone.temperature.value = (d['temperature'] ?? 0.0).toDouble();
                zone.ph.value = (d['ph'] ?? 0.0).toDouble();
                zone.ec.value = (d['ec'] ?? 0.0).toDouble();
                zone.azote.value = (d['n'] ?? 0.0).toDouble();
                zone.phosphore.value = (d['p'] ?? 0.0).toDouble();
                zone.potassium.value = (d['k'] ?? 0.0).toDouble();
                zone.sante.value = (d['sante'] ?? 0).toInt();

                // ✅ Vérifier l'expiration à chaque mise à jour (très important si l'app était fermée)
                _checkAndResumeTimer(uid, zone, d);

                debugPrint("🔄 [ZONES] Zone ${doc.id} mise à jour — enabled=${zone.enabled.value} status=${zone.irrigationStatus.value}");
              } else {
                final newZone = Zone(
                  id: doc.id,
                  name: d['name'] ?? 'Zone',
                  zoneNum: d['zone_num'] ?? doc.id.replaceAll('zone', ''),
                  plantType: plantType,
                  status: d['enabled'] ?? false,
                  irrigationStatus: d['irrigation_status'] ?? 'IDLE',
                  humidity: (d['humidity'] ?? 0.0).toDouble(),
                  temperature: (d['temperature'] ?? 0.0).toDouble(),
                  ph: (d['ph'] ?? 0.0).toDouble(),
                  ec: (d['ec'] ?? 0.0).toDouble(),
                  azote: (d['n'] ?? 0.0).toDouble(),
                  phosphore: (d['p'] ?? 0.0).toDouble(),
                  potassium: (d['k'] ?? 0.0).toDouble(),
                  sante: (d['sante'] ?? 0).toInt(),
                );
                zones.add(newZone);
                debugPrint("➕ [ZONES] Nouvelle zone ajoutée : ${doc.id}");

                // ✅ Vérifier l'état au démarrage
                _checkAndResumeTimer(uid, newZone, d);
              }
            }

            // Supprimer les zones supprimées de Firestore
            final firestoreIds = snapshot.docs.map((d) => d.id).toSet();
            zones.removeWhere((z) => !firestoreIds.contains(z.id));
          },
          onError: (e) {
            debugPrint("❌ [ZONES] Erreur Firestore: $e");
          },
        );
  }

  void basculerPompe(Zone zone, bool val) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    zone.enabled.value = val;
    if (!val) {
      _cancelZoneTimer(zone);
    }
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zone.id)
        .update({'enabled': val});
  }

  /// ✅ Méthode principale appelée depuis ThresholdsController
  Future<void> startTimedIrrigation({
    required String zoneId,
    required String zoneName,
    required int totalSeconds,
  }) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final zoneIndex = zones.indexWhere((z) => z.id == zoneId);
    if (zoneIndex < 0) return;
    final zone = zones[zoneIndex];

    if (zone.isIrrigating.value) {
      debugPrint("⚠️ [ZONES] Arrosage déjà en cours pour $zoneId");
      return;
    }

    debugPrint("🚀 [ZONES] Lancement arrosage persistant: $totalSeconds s pour $zoneId");

    // 1. Écrire dans Firestore
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .update({
      'timed_order_seconds': totalSeconds,
      'enabled': true,
      'irrigation_status': 'STARTED',
      'irrigation_mode': 'manual',
      'irrigation_started_at': FieldValue.serverTimestamp(),
    });

    // 2. Démarrer le timer persistant
    _startZoneTimer(uid, zone, totalSeconds);

    final minutes = totalSeconds ~/ 60;
    Get.snackbar(
      "💧 Irrigation lancée",
      "Arrosage de $minutes min en cours pour $zoneName",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// ✅ Démarre (ou reprend) le timer pour une zone
  void _startZoneTimer(String uid, Zone zone, int seconds) {
    _irrigationTimers[zone.id]?.cancel();

    zone.isIrrigating.value = true;
    zone.remainingSeconds.value = seconds;

    _irrigationTimers[zone.id] = Timer.periodic(const Duration(seconds: 1), (timer) async {
      zone.remainingSeconds.value--;
      if (zone.remainingSeconds.value <= 0) {
        await _finishIrrigation(uid, zone);
      }
    });

    debugPrint("⏱️ [ZONES] Timer démarré pour ${zone.id} — $seconds s restants");
  }

  /// ✅ Vérifie si une zone doit avoir son timer actif ou si elle a expiré
  void _checkAndResumeTimer(String uid, Zone zone, Map<String, dynamic> data) {
    final bool enabled = data['enabled'] ?? false;
    final String status = data['irrigation_status'] ?? 'IDLE';
    final int totalSeconds = (data['timed_order_seconds'] ?? 0) as int;
    final Timestamp? startedAt = data['irrigation_started_at'] as Timestamp?;

    if (enabled && status == 'STARTED' && startedAt != null && totalSeconds > 0) {
      final elapsed = DateTime.now().difference(startedAt.toDate()).inSeconds;
      final remaining = totalSeconds - elapsed;

      if (remaining > 0) {
        // Ne redémarrer le timer que s'il ne tourne pas déjà
        if (!_irrigationTimers.containsKey(zone.id)) {
          debugPrint("⏳ [ZONES] Reprise du timer pour ${zone.id} ($remaining s)");
          _startZoneTimer(uid, zone, remaining);
        } else {
          // Optionnel : synchroniser le temps restant local avec Firestore si décalage > 5s
          if ((zone.remainingSeconds.value - remaining).abs() > 5) {
            zone.remainingSeconds.value = remaining;
          }
        }
      } else {
        // TEMPS ÉCOULÉ (pendant que l'app était fermée)
        debugPrint("🏁 [ZONES] Temps écoulé détecté pour ${zone.id}, fermeture...");
        _finishIrrigation(uid, zone);
      }
    }
  }

  /// ✅ Appelé à la fin du timer → met Firestore à OFF
  Future<void> _finishIrrigation(String uid, Zone zone) async {
    _irrigationTimers[zone.id]?.cancel();
    _irrigationTimers.remove(zone.id);
    zone.isIrrigating.value = false;
    zone.remainingSeconds.value = 0;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zone.id)
          .update({
        'enabled': false,
        'irrigation_status': 'FINISHED',
      });

      debugPrint("✅ [ZONES] Irrigation terminée pour ${zone.id} (Notification temporaire envoyée)");

      Get.snackbar(
        "irrigation_finished".tr,
        "irrigation_finished_msg".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint("❌ Erreur fin irrigation: $e");
    }
  }

  /// ✅ Arrêt manuel immédiat
  Future<void> stopTimedIrrigation(String zoneId) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final zoneIndex = zones.indexWhere((z) => z.id == zoneId);
    if (zoneIndex < 0) return;
    final zone = zones[zoneIndex];

    debugPrint("🛑 [ZONES] Arrêt manuel de l'irrigation pour $zoneId");
    await _finishIrrigation(uid, zone);
  }

  /// ✅ Annule le timer localement (sans toucher Firestore)
  void _cancelZoneTimer(Zone zone) {
    _irrigationTimers[zone.id]?.cancel();
    _irrigationTimers.remove(zone.id);
    zone.isIrrigating.value = false;
    zone.remainingSeconds.value = 0;
    debugPrint("🛑 [ZONES] Timer annulé pour ${zone.id}");
  }

  /// ✅ Getter public pour que ThresholdsController lise l'état
  Zone? getZone(String zoneId) {
    final idx = zones.indexWhere((z) => z.id == zoneId);
    return idx >= 0 ? zones[idx] : null;
  }

  Future<void> supprimerZone(String zoneId) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .delete();
  }
}
