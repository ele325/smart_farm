import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryData {
  final DateTime time;
  final double humidity;
  final double temperature;
  final double ph;
  final double azote;
  final double phosphore;
  final double potassium;
  final double ec;
  final double waterConsumption;

  HistoryData({
    required this.time,
    required this.humidity,
    required this.temperature,
    required this.ph,
    required this.azote,
    required this.phosphore,
    required this.potassium,
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
    if (uid == null) {
      print("❌ [HISTORY] Utilisateur non connecté");
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    selectedPeriod.value = hours;
    DateTime startTime = DateTime.now().subtract(Duration(hours: hours));

    print("🔍 [HISTORY] Chargement historique pour zone: $zoneId, période: $hours h");
    print("🔍 [HISTORY] Chemin: users/$uid/zones/$zoneId/history");

    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .collection('history')
        .where('time', isGreaterThan: Timestamp.fromDate(startTime))
        .orderBy('time', descending: false)
        .snapshots()
        .listen((snapshot) {
          print("📦 [HISTORY] Docs reçus: ${snapshot.docs.length}");

          if (snapshot.docs.isEmpty) {
            print("⚠️ [HISTORY] Aucune donnée dans la période sélectionnée");
            historyRecords.clear();
            isLoading.value = false;
            return;
          }

          double cumulativeWater = 0.0;

          historyRecords.value = snapshot.docs.map((doc) {
            var data = doc.data();
            print("📄 [HISTORY] Doc: ${doc.id} => $data");

            double hum  = (data['humidity']    ?? 0.0).toDouble();
            double temp = (data['temperature'] ?? 0.0).toDouble();
            double phV  = (data['ph']          ?? 0.0).toDouble();
            double n    = (data['azote']       ?? 0.0).toDouble();
            double p    = (data['phosphore']   ?? 0.0).toDouble();
            double k    = (data['potassium']   ?? 0.0).toDouble();
            double ecV  = (data['ec']          ?? 0.0).toDouble();

            DateTime date;
            try {
              date = (data['time'] as Timestamp).toDate();
            } catch (e) {
              print("⚠️ [HISTORY] Erreur parsing time: $e");
              date = DateTime.now();
            }

            cumulativeWater += 0.25;

            return HistoryData(
              time: date,
              humidity: hum,
              temperature: temp,
              ph: phV,
              azote: n,
              phosphore: p,
              potassium: k,
              ec: ecV,
              waterConsumption: cumulativeWater,
            );
          }).toList();

          isLoading.value = false;
          print("✅ [HISTORY] ${historyRecords.length} enregistrements chargés");
        },
        onError: (e) {
          print("❌ [HISTORY] Erreur Firestore: $e");
          isLoading.value = false;
        });
  }
}