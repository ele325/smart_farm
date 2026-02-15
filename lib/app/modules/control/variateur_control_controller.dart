import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class VariateurControlController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Récupère le chemin du document variateur propre à l'utilisateur connecté
  String get _userDocPath => 'users/${_auth.currentUser?.uid}/commands/variateur';
  String get _userLogsPath => 'users/${_auth.currentUser?.uid}/pump_logs';

  // Le flux en temps réel filtré par utilisateur
  Stream<DocumentSnapshot> get variateurStream {
    return _firestore.doc(_userDocPath).snapshots();
  }

  Future<bool> sendCommand(double frequency, bool isOn) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      // 1. Mise à jour de la commande (Lue par l'ESP32)
      // Note : On n'utilise pas .tr sur les clés Firebase pour garder la compatibilité avec l'ESP32
      await _firestore.doc(_userDocPath).set({
        'frequency': frequency.roundToDouble(),
        'isOn': isOn,
        'lastUpdate': FieldValue.serverTimestamp(),
        'userEmail': user.email ?? "unknown",
      }, SetOptions(merge: true));

      // 2. Ajout à l'historique personnel (Pour la page History)
      await _firestore.collection(_userLogsPath).add({
        'action': isOn ? "ON" : "OFF",
        'freq': frequency.roundToDouble(),
        'user': user.email ?? "system",
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint("Erreur Firestore: $e");
      return false;
    }
  }
}