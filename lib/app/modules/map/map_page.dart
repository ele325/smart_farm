import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'map_controller.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapPageController());

    return Scaffold(
      body: Stack(
        children: [
          // 1. LA CARTE (Optimisée : Seuls les marqueurs sont réactifs)
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.farmCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.robocare.app',
              ),
              Obx(() => MarkerLayer(markers: controller.myMarkers.toList())),
            ],
          ),

          // 2. MÉTÉO (Haut)
          Positioned(top: 50, left: 20, right: 20, child: _buildWeatherBar(controller)),

          // 3. FILTRES (Bas Gauche) - Ajout du pH
          Positioned(
            bottom: 30, left: 15,
            child: Column(
              children: [
                _layerBtn(controller, 'stress_hydrique', Icons.water_drop, Colors.blue),
                const SizedBox(height: 10),
                _layerBtn(controller, 'ph', Icons.science, Colors.teal),
                const SizedBox(height: 10),
                _layerBtn(controller, 'azote', Icons.eco, Colors.orange),
                const SizedBox(height: 10),
                _layerBtn(controller, 'maladies', Icons.bug_report, Colors.purple),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _layerBtn(MapPageController c, String layer, IconData icon, Color color) {
    return Obx(() {
      bool sel = c.selectedLayer.value == layer;
      return GestureDetector(
        onTap: () => c.selectedLayer.value = layer,
        child: CircleAvatar(
          backgroundColor: sel ? color : Colors.white,
          radius: 25,
          child: Icon(icon, color: sel ? Colors.white : color),
        ),
      );
    });
  }

  Widget _buildWeatherBar(MapPageController c) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
      child: Obx(() => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network("https://openweathermap.org/img/wn/${c.weatherIconCode.value}@2x.png", width: 40),
          const SizedBox(width: 10),
          Text(c.weatherTemp.value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      )),
    );
  }
}