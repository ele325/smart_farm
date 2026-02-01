import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../modules/history/history_page.dart'; 

class MapPageController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var weatherTemp = ".".obs;
  var weatherDescription = "loading".tr.obs; // Utilise 'loading'
  var weatherIconCode = "01d".obs;

  final ll.LatLng farmCenter = const ll.LatLng(34.7333, 10.7667);
  RxList<Marker> myMarkers = <Marker>[].obs;
  var selectedLayer = 'stress_hydrique'.obs; 

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
    ever(selectedLayer, (_) => ecouterParcelles()); 
    ecouterParcelles();
  }

  Future<void> fetchWeather() async {
    const apiKey = "a9af5061732d5deaa7638c80ad945659"; 
    const url = "https://api.openweathermap.org/data/2.5/weather?q=Sfax&appid=$apiKey&units=metric&lang=${Get.locale?.languageCode ?? 'fr'}";
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
    _firestore.collection('zones').snapshots().listen((snap) {
      myMarkers.value = snap.docs.map((doc) {
        var data = doc.data();
        int valeurAffichee;
        if (selectedLayer.value == 'azote') {
          valeurAffichee = (data['azote'] ?? 0).toInt();
        } else if (selectedLayer.value == 'maladies') {
          valeurAffichee = (data['sante'] ?? 0).toInt();
        } else {
          valeurAffichee = (data['humidity'] ?? 0).toInt();
        }

        return Marker(
          point: ll.LatLng(data['lat'] ?? 34.7333, data['lng'] ?? 10.7667),
          width: 45, height: 45,
          child: GestureDetector(
            onTap: () => _showDetails(data['name'] ?? 'Zone', valeurAffichee, doc.id),
            child: _buildMarker(valeurAffichee, selectedLayer.value),
          ),
        );
      }).toList();
    });
  }

  Widget _buildMarker(int valeur, String type) {
    Color color = Colors.green;
    if (type == 'stress_hydrique' && valeur < 30) color = Colors.red;
    if (type == 'azote' && valeur < 40) color = Colors.orange;
    if (type == 'maladies' && valeur < 60) color = Colors.purple;

    return Container(
      decoration: BoxDecoration(
        color: color, shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Icon(_getIconForLayer(type), size: 20, color: Colors.white),
    );
  }

  IconData _getIconForLayer(String type) {
    if (type == 'azote') return Icons.eco;
    if (type == 'maladies') return Icons.bug_report;
    return Icons.water_drop;
  }

  void _showDetails(String name, int val, String docId) {
    String conseil = "";
    Color conseilColor = (val < 30) ? Colors.redAccent : Colors.green;
    
    // Logique de conseil traduite
    if (val < 30) {
      conseil = "critique".tr; // Utilise 'critique' de tes traductions
    } else if (val < 50) {
      conseil = "attention".tr; // Utilise 'attention'
    } else {
      conseil = "optimal".tr; // Utilise 'optimal'
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(conseil, style: TextStyle(color: conseilColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
                icon: const Icon(Icons.show_chart),
                label: Text("history".tr), // Traduit "Historique"
                onPressed: () {
                  Get.back();
                  Get.to(() => HistoryPage(zoneName: name, zoneId: docId));
                },
              ),
            ),
            const SizedBox(height: 15),
            Text("analysis_24h".tr, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }
}