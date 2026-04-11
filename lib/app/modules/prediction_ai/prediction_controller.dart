import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AlertLevel { success, info, warning, danger }

class PredictionController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── État général ──────────────────────────────────────────────────────────
  var isLoading = true.obs;
  var zones = <Map<String, dynamic>>[].obs;
  var selectedZoneIndex = 0.obs;

  // ── Score de risque ML ────────────────────────────────────────────────────
  var currentScore = 0.obs;
  var currentReason = ''.obs;
  var isDangerous = false.obs;

  // ── Score de santé agronomique ────────────────────────────────────────────
  var healthScore = 0.obs;

  // ── Prédictions prochain cycle ────────────────────────────────────────────
  var predHumidity = 0.0.obs;
  var predTemp = 0.0.obs;
  var predEc = 0.0.obs;
  var predN = 0.0.obs;
  var predP = 0.0.obs;
  var predK = 0.0.obs;

  // ── Tendances ─────────────────────────────────────────────────────────────
  var trendH = 0.0.obs;
  var trendT = 0.0.obs;
  var trendEc = 0.0.obs;
  var trendN = 0.0.obs;
  var trendP = 0.0.obs;
  var trendK = 0.0.obs;

  // ── Intervalles de confiance & qualité modèle ─────────────────────────────
  var ciLow = 0.0.obs;
  var ciHigh = 0.0.obs;
  var r2Humidity = 0.0.obs;

  // ── Historique pour graphiques ─────────────────────────────────────────────
  var humidityHistory = <double>[].obs;
  var tempHistory = <double>[].obs;
  var ecHistory = <double>[].obs;
  var timestampHistory = <DateTime>[].obs;

  // ── Alertes et conseils ───────────────────────────────────────────────────
  var alerts = <Map<String, dynamic>>[].obs;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadZones();
  }

  // ── Chargement de toutes les zones ────────────────────────────────────────
  Future<void> _loadZones() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      isLoading.value = true;

      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .get();

      zones.value = snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      if (zones.isNotEmpty) {
        await loadZoneData(0);
      }
    } catch (e) {
      debugPrint('Erreur chargement zones: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Chargement des données d'une zone ─────────────────────────────────────
  Future<void> loadZoneData(int index) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || index >= zones.length) return;

    selectedZoneIndex.value = index;
    isLoading.value = true;

    try {
      final zoneId = zones[index]['id'] as String;

      // ── Dernière prédiction ML écrite par predictor.py ────────────────────
      final predSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .collection('history')
          .where('type', isEqualTo: 'irrigation_combined')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (predSnap.docs.isNotEmpty) {
        final data = predSnap.docs.first.data();

        currentScore.value = (data['score'] ?? 0) as int;
        currentReason.value = data['raison'] ?? '';
        isDangerous.value = currentScore.value >= 60;

        predHumidity.value = (data['pred_humidity'] ?? 0.0).toDouble();
        predTemp.value = (data['pred_temp'] ?? 0.0).toDouble();
        predEc.value = (data['pred_ec'] ?? 0.0).toDouble();
        predN.value = (data['pred_n'] ?? 0.0).toDouble();
        predP.value = (data['pred_p'] ?? 0.0).toDouble();
        predK.value = (data['pred_k'] ?? 0.0).toDouble();

        trendH.value = (data['trend_humidity'] ?? 0.0).toDouble();
        trendT.value = (data['trend_temp'] ?? 0.0).toDouble();
        trendEc.value = (data['trend_ec'] ?? 0.0).toDouble();
        trendN.value = (data['trend_n'] ?? 0.0).toDouble();
        trendP.value = (data['trend_p'] ?? 0.0).toDouble();
        trendK.value = (data['trend_k'] ?? 0.0).toDouble();

        ciLow.value = (data['ci_humidity_low'] ?? 0.0).toDouble();
        ciHigh.value = (data['ci_humidity_high'] ?? 0.0).toDouble();
        r2Humidity.value = (data['r2_humidity'] ?? 0.0).toDouble();
      }

      // ── Score de santé du sol (champ 'sante' écrit par health_score.py) ──
      healthScore.value = (zones[index]['sante'] ?? 5) as int;

      // ── Historique brut capteurs (30 derniers relevés) ────────────────────
      final histSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('zones')
          .doc(zoneId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();

      final records = histSnap.docs.reversed.toList();

      humidityHistory.value = records
          .map((d) => (d.data()['humidity'] ?? 0.0).toDouble())
          .toList()
          .cast<double>();

      tempHistory.value = records
          .map((d) => (d.data()['temperature'] ?? 0.0).toDouble())
          .toList()
          .cast<double>();

      ecHistory.value = records
          .map((d) => (d.data()['ec'] ?? 0.0).toDouble())
          .toList()
          .cast<double>();

      timestampHistory.value = records.map((d) {
        final ts = d.data()['timestamp'];
        if (ts is Timestamp) return ts.toDate();
        return DateTime.now();
      }).toList();

      // ── Construction des alertes et conseils ──────────────────────────────
      _buildAlerts();
    } catch (e) {
      debugPrint('Erreur loadZoneData: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Génération des alertes à partir de la raison ML ───────────────────────
  void _buildAlerts() {
    alerts.clear();

    // Conseil global selon le score
    if (isDangerous.value) {
      alerts.add({
        'message': 'irrigation_urgent_conseil'.tr,
        'level': AlertLevel.danger,
      });
    } else if (currentScore.value >= 30) {
      alerts.add({
        'message': 'irrigation_watch_conseil'.tr,
        'level': AlertLevel.warning,
      });
    } else {
      alerts.add({
        'message': 'soil_healthy_conseil'.tr,
        'level': AlertLevel.success,
      });
    }

    // Détail des raisons générées par le ML
    if (currentReason.value.isNotEmpty &&
        currentReason.value != 'Conditions normales') {
      final reasons = currentReason.value.split(' | ');
      for (final r in reasons) {
        if (r.trim().isEmpty) continue;

        AlertLevel level = AlertLevel.info;
        if (r.contains('critique') || r.contains('excessive')) {
          level = AlertLevel.danger;
        } else if (r.contains('bas') ||
            r.contains('basse') ||
            r.contains('Chute') ||
            r.contains('chute') ||
            r.contains('IC')) {
          level = AlertLevel.warning;
        }

        alerts.add({'message': r.trim(), 'level': level});
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get selectedZoneName {
    if (zones.isEmpty || selectedZoneIndex.value >= zones.length) return '';
    return zones[selectedZoneIndex.value]['name'] ?? 'Zone';
  }

  Color get riskColor {
    if (currentScore.value >= 60) return const Color(0xFFE53E3E);
    if (currentScore.value >= 30) return const Color(0xFFED8936);
    return const Color(0xFF38A169);
  }
}