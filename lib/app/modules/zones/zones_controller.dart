import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Zone {
  final String id;
  final String name;
  RxBool enabled;
  final int humidity;

  Zone({required this.id, required this.name, required bool status, required this.humidity})
      : enabled = status.obs;
}

class ZonesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // RxList est une liste observable qui déclenche l'UI à chaque changement
  RxList<Zone> zones = <Zone>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Liaison dynamique : dès que Firebase change, 'zones' se met à jour
    zones.bindStream(listenToZones());
  }

  Stream<List<Zone>> listenToZones() {
    return _firestore.collection('zones')
        .orderBy('name') // Pour garder l'ordre alphabétique (Zone 1, 2, 3...)
        .snapshots()
        .map((query) {
      return query.docs.map((doc) {
        return Zone(
          id: doc.id,
          name: doc.get('name') ?? 'Zone sans nom',
          status: doc.get('enabled') ?? false,
          humidity: (doc.get('humidity') ?? 0).toInt(),
        );
      }).toList();
    });
  }

  void toggleZone(Zone zone, bool newValue) async {
    try {
      zone.enabled.value = newValue; // Mise à jour immédiate à l'écran
      await _firestore.collection('zones').doc(zone.id).update({
        'enabled': newValue,
      });
    } catch (e) {
      zone.enabled.value = !newValue; // Retour arrière en cas d'erreur
      Get.snackbar("Erreur", "Connexion perdue", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}