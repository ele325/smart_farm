import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zones_controller.dart';

class ZonesPage extends StatelessWidget {
  ZonesPage({super.key});

  // Injection du contrôleur mis à jour avec NPK et EC
  final ZonesController controller = Get.put(ZonesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('zones_management'.tr),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.zones.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.zones.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62, // Ajusté pour accueillir les badges NPK
          ),
          itemBuilder: (context, index) =>
              _construireCarteZone(controller.zones[index]),
        );
      }),
    );
  }

  Widget _construireCarteZone(Zone zone) {
    return Obx(() {
      // Alerte si humidité basse
      bool estEnAlerte = zone.humidity.value < 30;

      return Card(
        elevation: estEnAlerte ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: estEnAlerte ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              // --- ENTÊTE ---
              Icon(
                estEnAlerte ? Icons.warning_amber_rounded : Icons.eco,
                color: estEnAlerte ? Colors.red : Colors.green,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                zone.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(),

              // --- DONNÉES PHYSIQUES ---
              _buildSensorRow(Icons.opacity, "${zone.humidity.value.toStringAsFixed(1)}%", Colors.blue),
              _buildSensorRow(Icons.thermostat, "${zone.temperature.value.toStringAsFixed(1)}°C", Colors.orange),
              _buildSensorRow(Icons.science, "pH: ${zone.ph.value.toStringAsFixed(1)}", Colors.teal),
              _buildSensorRow(Icons.bolt, "EC: ${zone.ec.value.toInt()}", Colors.purple),

              const SizedBox(height: 8),

              // --- BADGES NPK (Nutriments) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _npkBadge("N", zone.azote.value, Colors.redAccent),
                  _npkBadge("P", zone.phosphore.value, Colors.orangeAccent),
                  _npkBadge("K", zone.potassium.value, Colors.blueAccent),
                ],
              ),

              const Spacer(),

              // --- CONTRÔLE POMPE ---
              Switch(
                value: zone.enabled.value,
                onChanged: (val) => controller.basculerPompe(zone, val),
                activeColor: estEnAlerte ? Colors.red : Colors.blue,
              ),
              Text(
                zone.enabled.value ? 'running'.tr : 'stopped'.tr,
                style: TextStyle(
                  color: zone.enabled.value ? Colors.blue : Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Ligne de capteur standard
  Widget _buildSensorRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Petit badge circulaire pour N, P et K
  Widget _npkBadge(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${value.toInt()}",
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}