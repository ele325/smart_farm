import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zones_controller.dart';

class ZonesPage extends StatelessWidget {
  ZonesPage({super.key});
  final ZonesController controller = Get.put(ZonesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('zones_management'.tr),
        backgroundColor: Colors.green[800],
        centerTitle: true,
      ),
      body: Obx(() {
        // État de chargement initial
        if (controller.zones.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        // Affichage dynamique en grille (parfait pour tes 8 zones)
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.zones.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 colonnes pour voir les parcelles
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9, // Ajuste la hauteur des cartes
          ),
          itemBuilder: (context, index) {
            final zone = controller.zones[index];
            return _buildZoneCard(zone);
          },
        );
      }),
    );
  }

  Widget _buildZoneCard(Zone zone) {
    return Obx(() => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: zone.enabled.value 
              ? [Colors.blue.shade50, Colors.white] 
              : [Colors.grey.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop, 
                color: zone.enabled.value ? Colors.blue : Colors.grey, 
                size: 40
              ),
              const SizedBox(height: 10),
              Text(
                zone.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text("${'humidity'.tr}: ${zone.humidity}%"),
              const Spacer(),
              Switch(
                value: zone.enabled.value,
                onChanged: (val) => controller.toggleZone(zone, val),
                activeColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}