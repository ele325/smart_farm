import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryData {
  final DateTime time;
  final double humidity;
  final double temperature;
  final double ph;
  final double n;           // ✅ était: azote
  final double p;           // ✅ était: phosphore
  final double k;           // ✅ était: potassium
  final double ec;
  final double waterConsumption;

  HistoryData({
    required this.time,
    required this.humidity,
    required this.temperature,
    required this.ph,
    required this.n,        // ✅
    required this.p,        // ✅
    required this.k,        // ✅
    required this.ec,
    this.waterConsumption = 0.0,
  });
}

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxList<HistoryData> historyRecords = <HistoryData>[].obs;
  RxBool isLoading = true.obs;
  RxInt selectedPeriod = 24.obs;

  void fetchHistory(String zoneId, int hours) {
    String? uid = _auth.currentUser?.uid;
    if (uid == null || zoneId.isEmpty) {
      print("❌ [HISTORY] Erreur : UID ou ZoneId vide.");
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    selectedPeriod.value = hours;
    DateTime startTime = DateTime.now().subtract(Duration(hours: hours));

    print("🔍 [HISTORY] Chargement : users/$uid/zones/$zoneId/measures");

    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .collection('measures')
        .where('last_update', isGreaterThan: Timestamp.fromDate(startTime))
        .orderBy('last_update', descending: false)
        .snapshots()
        .listen((snapshot) {
          print("📦 [HISTORY] Documents reçus : ${snapshot.docs.length}");

          if (snapshot.docs.isEmpty) {
            print("⚠️ [HISTORY] Aucune donnée trouvée.");
            historyRecords.clear();
            isLoading.value = false;
            return;
          }

          double cumulativeWater = 0.0;

          historyRecords.value = snapshot.docs.map((doc) {
            var data = doc.data();

            double hum  = (data['humidity']    ?? 0.0).toDouble();
            double temp = (data['temperature'] ?? 0.0).toDouble();
            double phV  = (data['ph']          ?? 0.0).toDouble();
            double nV   = (data['n']           ?? 0.0).toDouble(); // ✅ était 'azote'
            double pV   = (data['p']           ?? 0.0).toDouble(); // ✅ était 'phosphore'
            double kV   = (data['k']           ?? 0.0).toDouble(); // ✅ était 'potassium'
            double ecV  = (data['ec']          ?? 0.0).toDouble();

            DateTime date;
            try {
              date = (data['last_update'] as Timestamp).toDate();
            } catch (e) {
              print("⚠️ [HISTORY] Erreur date : $e");
              date = DateTime.now();
            }

            cumulativeWater += 0.25;

            return HistoryData(
              time:             date,
              humidity:         hum,
              temperature:      temp,
              ph:               phV,
              n:                nV,  // ✅
              p:                pV,  // ✅
              k:                kV,  // ✅
              ec:               ecV,
              waterConsumption: cumulativeWater,
            );
          }).toList();

          isLoading.value = false;
        },
        onError: (e) {
          print("❌ [HISTORY] Erreur Firestore : $e");
          isLoading.value = false;
        });
  }
}