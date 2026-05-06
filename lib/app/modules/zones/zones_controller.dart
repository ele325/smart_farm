import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class Zone {
  final String id;
  final String name;
  final String zoneNum;
  // ✅ Ordre correct des déclarations
  RxString plantType;
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
    required this.zoneNum,
    required String plantType,
    required bool status,
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
      print("❌ [ZONES] Utilisateur non connecté");
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
            print(
              "📦 [ZONES] ${snapshot.docs.length} zones reçues depuis Firebase",
            );

            final zoneList = await Future.wait(
              snapshot.docs.map((doc) async {
                final d = doc.data();
                String plantType = (d['plant_type'] ?? '').toString();

                final plantSnap = await doc.reference
                    .collection('plante')
                    .doc('current')
                    .get();
                if (plantSnap.exists) {
                  final plantData = plantSnap.data();
                  plantType = (plantData?['plant_type'] ?? plantType)
                      .toString();
                }

                return Zone(
                  id: doc.id,
                  name: d['name'] ?? 'Zone',
                  zoneNum: d['zone_num'] ?? doc.id.replaceAll('zone', ''),
                  plantType: plantType,
                  status: d['enabled'] ?? false,
                  humidity: (d['humidity'] ?? 0.0).toDouble(),
                  temperature: (d['temperature'] ?? 0.0).toDouble(),
                  ph: (d['ph'] ?? 0.0).toDouble(),
                  ec: (d['ec'] ?? 0.0).toDouble(),
                  azote: (d['n'] ?? 0.0).toDouble(),
                  phosphore: (d['p'] ?? 0.0).toDouble(),
                  potassium: (d['k'] ?? 0.0).toDouble(),
                  sante: (d['sante'] ?? 0).toInt(),
                );
              }),
            );
            zones.assignAll(zoneList);
          },
          onError: (e) {
            print("❌ [ZONES] Erreur Firestore: $e");
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

  Future<void> supprimerZone(String zoneId) async {
    final String? uid = _auth.currentUser?.uid;
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
