import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../modules/history/history_page.dart'; 

class MapPageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MapController mapController = MapController();

  var weatherTemp = ".".obs;
  var weatherDescription = "loading".tr.obs; 
  var weatherIconCode = "01d".obs;

  final ll.LatLng farmCenter = const ll.LatLng(34.7333, 10.7667);
  RxList<Marker> myMarkers = <Marker>[].obs;
  var selectedLayer = 'stress_hydrique'.obs; 
  bool hasCentered = false;

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
    ever(selectedLayer, (_) => ecouterParcelles()); 
    ecouterParcelles();
  }

  Future<void> fetchWeather() async {
    const apiKey = "a9af5061732d5deaa7638c80ad945659"; 
    String lang = Get.locale?.languageCode ?? 'fr';
    final url = "https://api.openweathermap.org/data/2.5/weather?q=Sfax&appid=$apiKey&units=metric&lang=$lang";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weatherTemp.value = "${data['main']['temp'].round()}°C";
        weatherDescription.value = data['weather'][0]['description'];
        weatherIconCode.value = data['weather'][0]['icon'];
      }
    } catch (e) { print("Erreur Météo: $e"); }
  }

  void ecouterParcelles() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _firestore.collection('users').doc(uid).collection('zones').snapshots().listen((snap) {
      if (snap.docs.isEmpty) return;

      myMarkers.value = snap.docs.map((doc) {
        var data = doc.data();
        double val;
        
        // Sélection de la donnée selon le filtre
        if (selectedLayer.value == 'azote') val = (data['azote'] ?? 0.0).toDouble();
        else if (selectedLayer.value == 'maladies') val = (data['sante'] ?? 0.0).toDouble();
        else if (selectedLayer.value == 'ph') val = (data['ph'] ?? 0.0).toDouble();
        else val = (data['humidity'] ?? 0.0).toDouble();

        return Marker(
          point: ll.LatLng(data['lat'] ?? 34.7333, data['lng'] ?? 10.7667),
          width: 50, height: 50,
          child: GestureDetector(
            onTap: () => _showDetails(data['name'] ?? 'Zone', val, doc.id),
            child: _buildMarker(val, selectedLayer.value),
          ),
        );
      }).toList();

      if (!hasCentered && myMarkers.isNotEmpty) {
        mapController.move(myMarkers.first.point, 15.0);
        hasCentered = true;
      }
    });
  }

  Widget _buildMarker(double valeur, String type) {
    Color color = Colors.green;
    if (type == 'stress_hydrique' && valeur < 30) color = Colors.red;
    else if (type == 'azote' && valeur < 40) color = Colors.orange;
    else if (type == 'maladies' && valeur < 60) color = Colors.purple;
    else if (type == 'ph' && (valeur < 6.0 || valeur > 8.0)) color = Colors.redAccent;
    else if (type == 'ph') color = Colors.teal;

    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
      child: Icon(_getIconForLayer(type), size: 22, color: Colors.white),
    );
  }

  IconData _getIconForLayer(String type) {
    if (type == 'azote') return Icons.eco;
    if (type == 'maladies') return Icons.bug_report;
    if (type == 'ph') return Icons.science;
    return Icons.water_drop;
  }

  void _showDetails(String name, double val, String docId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${selectedLayer.value.tr}: ${val.toStringAsFixed(1)}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], minimumSize: const Size(double.infinity, 50)),
              onPressed: () { Get.back(); Get.to(() => HistoryPage(zoneName: name, zoneId: docId)); },
              child: Text("history".tr, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}