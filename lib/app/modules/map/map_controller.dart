import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll; // ll = LatLong pour éviter les erreurs
import '../../widgets/info_card.dart'; 
import '../../widgets/app_button.dart';

class MapPageController extends GetxController {
  // On utilise ll.LatLng pour forcer l'usage du bon package
  final ll.LatLng farmCenter = ll.LatLng(34.7333, 10.7667);
  
  var myMarkers = <Marker>[].obs;
  var myPolygons = <Polygon>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMapData();
  }

  void loadMapData() {
    // Nettoyage avant chargement
    myMarkers.clear();
    myPolygons.clear();

    // 1. Ajout d'un marqueur de stress avec TON design
    myMarkers.add(
      Marker(
        point: ll.LatLng(34.7335, 10.7668),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => showStressDetails(
            "Zone Nord", 
            "Stress Hydrique Sévère", 
            "L'humidité est tombée à 15%. Activez l'irrigation.", 
            Colors.red
          ),
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
      ),
    );

    // 2. Zone de Heatmap (Polygone rouge transparent)
    myPolygons.add(
      Polygon(
        points: [
          ll.LatLng(34.7336, 10.7665),
          ll.LatLng(34.7339, 10.7670),
          ll.LatLng(34.7334, 10.7674),
        ],
        color: Colors.red.withValues(alpha: 0.3),
        isFilled: true,
        borderStrokeWidth: 2,
        borderColor: Colors.red,
      ),
    );

    isLoading.value = false;
  }

  void showStressDetails(String zone, String type, String advice, Color color) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // UTILISATION DE TON WIDGET InfoCard
            InfoCard(
              title: "Alerte : $zone",
              value: type,
              icon: Icons.warning_amber_rounded,
              statusColor: color,
            ),
            const SizedBox(height: 15),
            Text(
              "💡 Conseil : $advice",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
            const SizedBox(height: 25),
            // UTILISATION DE TON WIDGET AppButton
            AppButton(
              title: "Compris",
              onTap: () => Get.back(),
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}