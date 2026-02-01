import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Modèle de donnée pour une Zone agricole
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
  
  // Liste réactive (Observable) des zones
  RxList<Zone> zones = <Zone>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Liaison temps réel : l'UI réagit instantanément aux modifs Firebase
    zones.bindStream(ecouterLesZones());
  }

  // Stream qui récupère les données de la collection 'zones'
  Stream<List<Zone>> ecouterLesZones() {
    return _firestore.collection('zones')
        .orderBy('name') 
        .snapshots()
        .map((query) {
      return query.docs.map((doc) {
        return Zone(
          id: doc.id,
          name: doc.get('name') ?? 'Zone Inconnue',
          status: doc.get('enabled') ?? false,
          humidity: (doc.get('humidity') ?? 0).toInt(),
        );
      }).toList();
    });
  }

  // Actionneur : Change l'état de la pompe dans Firebase
  void basculerPompe(Zone zone, bool nouvelleValeur) async {
    try {
      zone.enabled.value = nouvelleValeur; 
      await _firestore.collection('zones').doc(zone.id).update({
        'enabled': nouvelleValeur,
      });
    } catch (e) {
      zone.enabled.value = !nouvelleValeur; // Retour arrière si erreur réseau
      Get.snackbar('erreur'.tr, 'google_error'.tr, 
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}