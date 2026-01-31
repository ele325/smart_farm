import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:latlong2/latlong2.dart' as ll;
import 'package:latlong2/latlong.dart' as ll;
import '../map/map_controller.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapPageController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse Drone & Map'),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          options: MapOptions(
            initialCenter: controller.farmCenter,
            initialZoom: 17,
          ),
          children: [
            // Couche Satellite (ArcGIS/Esri - Gratuit et sans clé)
            TileLayer(
              urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.smartfarm.app',
            ),
            
            // Couche des zones colorées (Polygones)
            PolygonLayer(polygons: controller.myPolygons),
            
            // Couche des icônes (Marqueurs)
            MarkerLayer(markers: controller.myMarkers),
          ],
        );
      }),
    );
  }
}