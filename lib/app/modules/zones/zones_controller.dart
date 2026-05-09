import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Zone {
  final String id;
  final String name;
  final String zoneNum;
  // ✅ Nouveaux champs pour supervision
  RxString plantType;
  RxBool enabled;
  RxString irrigationStatus;
  RxInt selectedDuration; // En secondes

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

  @override
  void onInit() {
    super.onInit();
    zones.clear();
    _ecouterLesZones();
  }

  @override
  void onClose() {
    _subscription?.cancel();
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

              // ✅ Chercher si la zone existe déjà
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
                // ✅ MISE À JOUR en place (garde la réactivité)
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
                debugPrint("🔄 [ZONES] Zone ${doc.id} mise à jour — enabled=${zone.enabled.value} status=${zone.irrigationStatus.value}");
              } else {
                // ✅ NOUVELLE zone : on l'ajoute
                zones.add(Zone(
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
                ));
                debugPrint("➕ [ZONES] Nouvelle zone ajoutée : ${doc.id}");
              }
            }

            // ✅ Supprimer les zones supprimées de Firestore
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
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zone.id)
        .update({'enabled': val});
  }

  void lancerArrosageTemporise(Zone zone) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final int seconds = zone.selectedDuration.value;
    debugPrint("🚀 [ZONES] Lancement arrosage temporisé: $seconds s pour ${zone.id}");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zone.id)
        .update({
          'timed_order_seconds': seconds,
        });

    Get.snackbar(
      'irrigation_alert'.tr,
      'irrigation_started_msg'.trParams({
        'minutes': (seconds ~/ 60).toString(),
        'zone': zone.name,
      }),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1B5E20),
      colorText: Colors.white,
    );
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
