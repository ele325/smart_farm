import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ThresholdsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String zoneId;
  final String zoneName;

  ThresholdsController({required this.zoneId, required this.zoneName});

  RxDouble minHumidity = 30.0.obs;
  RxDouble maxHumidity = 70.0.obs;
  RxInt duration = 15.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToSettings();
  }

  void _listenToSettings() {
    String? uid = _auth.currentUser?.uid;
    _firestore
        .collection('users')
        .doc(uid)
        .collection('zones')
        .doc(zoneId)
        .collection('config')
        .doc('thresholds')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            Map<String, dynamic> data = snapshot.data()!;
            minHumidity.value = (data['minHumidity'] ?? 30.0).toDouble();
            maxHumidity.value = (data['maxHumidity'] ?? 70.0).toDouble();
            duration.value = (data['duration'] ?? 15).toInt();
          }
        });
  }

  Future<bool> saveSettings() async {
    String? uid = _auth.currentUser?.uid;
    try {
      isLoading.value = true;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .collection('config')
          .doc('thresholds')
          .set({
            'minHumidity': minHumidity.value,
            'maxHumidity': maxHumidity.value,
            'duration': duration.value,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint("Erreur Firebase: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}