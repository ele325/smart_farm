import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryData {
  final DateTime time;
  final int value;
  HistoryData(this.time, this.value);
}

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<HistoryData> historyRecords = <HistoryData>[].obs;
  RxBool isLoading = true.obs;

  void fetchHistory(String zoneId) {
    if (zoneId.isEmpty) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    _firestore
        .collection('zones')
        .doc(zoneId)
        .collection('history')
        .orderBy('time', descending: false)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      historyRecords.value = snapshot.docs.map((doc) {
        // Sécurité : Vérifie que les champs existent avant de mapper
        return HistoryData(
          (doc.data().containsKey('time')) ? (doc['time'] as Timestamp).toDate() : DateTime.now(),
          (doc.data().containsKey('value')) ? (doc['value'] ?? 0).toInt() : 0,
        );
      }).toList();
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
      print("Erreur Firestore: $e");
    });
  }
}