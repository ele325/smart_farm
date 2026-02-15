import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importation nécessaire

class HistoryData {
  final DateTime time;
  final int value;
  HistoryData(this.time, this.value);
}

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance pour l'UID
  
  RxList<HistoryData> historyRecords = <HistoryData>[].obs;
  RxBool isLoading = true.obs;

  void fetchHistory(String zoneId) {
    String? uid = _auth.currentUser?.uid; // Récupération de l'utilisateur actuel

    if (zoneId.isEmpty || uid == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    
    // MISE À JOUR DU CHEMIN : users -> UID -> zones -> zoneId -> history
    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .collection('history')
        .orderBy('time', descending: false)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      historyRecords.value = snapshot.docs.map((doc) {
        var data = doc.data();
        return HistoryData(
          (data.containsKey('time')) ? (data['time'] as Timestamp).toDate() : DateTime.now(),
          (data.containsKey('humidity')) ? (data['humidity'] ?? 0).toInt() : 0,
        );
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      print("Erreur Firestore History: $e");
    });
  }
}