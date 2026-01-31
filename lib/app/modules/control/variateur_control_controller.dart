import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VariateurControlController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String docPath = 'commands/variateur';

  // Le flux en temps réel que tout le monde écoute
  Stream<DocumentSnapshot> get variateurStream => _firestore.doc(docPath).snapshots();

  Future<bool> sendCommand(double frequency, bool isOn) async {
    try {
      User? user = _auth.currentUser;

      // Mise à jour du document principal (État actuel)
      await _firestore.doc(docPath).set({
        'frequency': frequency.roundToDouble(),
        'isOn': isOn,
        'lastUpdate': FieldValue.serverTimestamp(),
        'updatedBy': user?.uid ?? "unknown_id",
        'userEmail': user?.email ?? "unknown_user",
      }, SetOptions(merge: true));

      // Ajout automatique à l'historique (Logs)
      await _firestore.collection('pump_logs').add({
        'action': isOn ? "ON" : "OFF",
        'freq': frequency.roundToDouble(),
        'user': user?.email ?? "system",
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint("Erreur Firestore: $e");
      return false;
    }
  }
}