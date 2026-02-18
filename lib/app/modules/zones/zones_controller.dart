import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Zone {
  final String id;
  final String name;
  final String zoneNum;
  RxBool   enabled;
  RxDouble humidity;
  RxDouble temperature;
  RxDouble ph;
  RxDouble ec;
  RxDouble azote;
  RxDouble phosphore;
  RxDouble potassium;
  RxInt    sante;

  Zone({
    required this.id,
    required this.name,
    required this.zoneNum,
    required bool   status,
    required double humidity,
    required double temperature,
    required double ph,
    required double ec,
    required double azote,
    required double phosphore,
    required double potassium,
    required int    sante,
  })  : enabled     = status.obs,
        humidity    = humidity.obs,
        temperature = temperature.obs,
        ph          = ph.obs,
        ec          = ec.obs,
        azote       = azote.obs,
        phosphore   = phosphore.obs,
        potassium   = potassium.obs,
        sante       = sante.obs;
}

class ZonesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  RxList<Zone> zones = <Zone>[].obs;
  StreamSubscription? _subscription; // ✅ garder référence au stream

  @override
  void onInit() {
    super.onInit();
    zones.clear(); // ✅ vider le cache au démarrage
    _ecouterLesZones();
  }

  @override
  void onClose() {
    _subscription?.cancel(); // ✅ annuler le stream proprement
    super.onClose();
  }

  void _ecouterLesZones() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      print("❌ [ZONES] Utilisateur non connecté");
      return;
    }

    // ✅ Annuler l'ancien stream avant d'en créer un nouveau
    _subscription?.cancel();

    _subscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .snapshots()
        .listen((snapshot) {
          print("📦 [ZONES] ${snapshot.docs.length} zones reçues depuis Firebase");

          // ✅ Remplacer entièrement la liste (gère suppressions + ajouts)
          zones.assignAll(
            snapshot.docs.map((doc) {
              final d = doc.data();
              return Zone(
                id:          doc.id,
                name:        d['name']        ?? 'Zone ?',
                zoneNum:     d['zone_num']    ?? '',
                status:      d['enabled']     ?? false,
                humidity:    (d['humidity']    ?? 0.0).toDouble(),
                temperature: (d['temperature'] ?? 0.0).toDouble(),
                ph:          (d['ph']          ?? 0.0).toDouble(),
                ec:          (d['ec']          ?? 0.0).toDouble(),
                azote:       (d['azote']       ?? 0.0).toDouble(),
                phosphore:   (d['phosphore']   ?? 0.0).toDouble(),
                potassium:   (d['potassium']   ?? 0.0).toDouble(),
                sante:       (d['sante']       ?? 0).toInt(),
              );
            }).toList(),
          );

        }, onError: (e) {
          print("❌ [ZONES] Erreur Firestore: $e");
        });
  }

  void basculerPompe(Zone zone, bool val) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    zone.enabled.value = val;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zone.id)
        .update({'enabled': val});
  }

  Future<void> supprimerZone(String zoneId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .delete();
    print("🗑️ [ZONES] Zone $zoneId supprimée");
  }
}