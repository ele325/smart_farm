import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// --- MODÈLE DE DONNÉE RÉACTIF ---
class Zone {
  final String id;
  final String name;
  RxBool enabled;
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
    required bool status,
    required double humidity,
    required double temperature,
    required double ph,
    required double ec,
    required double azote,
    required double phosphore,
    required double potassium,
    required int sante,
  })  : enabled = status.obs,
        humidity = humidity.obs,
        temperature = temperature.obs,
        ph = ph.obs,
        ec = ec.obs,
        azote = azote.obs,
        phosphore = phosphore.obs,
        potassium = potassium.obs,
        sante = sante.obs;
}

// --- CONTRÔLEUR ---
class ZonesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxList<Zone> zones = <Zone>[].obs;

  @override
  void onInit() {
    super.onInit();
    zones.bindStream(ecouterLesZones());
  }

  Stream<List<Zone>> ecouterLesZones() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('users').doc(uid).collection('zones')
        .snapshots().map((query) {
      return query.docs.map((doc) {
        final d = doc.data();
        return Zone(
          id: doc.id,
          name: d['name'] ?? 'Zone Inconnue',
          status: d['enabled'] ?? false,
          humidity: (d['humidity'] ?? 0.0).toDouble(),
          temperature: (d['temperature'] ?? 0.0).toDouble(),
          ph: (d['ph'] ?? 0.0).toDouble(),
          ec: (d['ec'] ?? 0.0).toDouble(),
          azote: (d['azote'] ?? 0.0).toDouble(),
          phosphore: (d['phosphore'] ?? 0.0).toDouble(),
          potassium: (d['potassium'] ?? 0.0).toDouble(),
          sante: (d['sante'] ?? 0).toInt(),
        );
      }).toList();
    });
  }

  void basculerPompe(Zone zone, bool val) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    zone.enabled.value = val;
    await _firestore.collection('users').doc(uid).collection('zones').doc(zone.id).update({'enabled': val});
  }
}