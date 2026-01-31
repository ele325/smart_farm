import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryData {
  final DateTime time;
  final int humidity;
  HistoryData(this.time, this.humidity);
}

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<HistoryData> historyRecords = <HistoryData>[].obs;
  RxBool isLoading = true.obs;

  void fetchHistory(String zoneId) {
    if (zoneId.isEmpty) return;
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
        return HistoryData(
          (doc['time'] as Timestamp).toDate(),
          (doc['value'] ?? 0).toInt(),
        );
      }).toList();
      isLoading.value = false;
    });
  }
}