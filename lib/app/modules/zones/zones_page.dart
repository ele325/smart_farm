import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zones_controller.dart';
import '../history/history_page.dart';

class ZonesPage extends StatelessWidget {
  ZonesPage({super.key});

  // Utilisation de permanent: true pour éviter les erreurs "Controller not found"
  final ZonesController controller = Get.put(
    ZonesController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    // Ajout du Scaffold avec AppBar comme dans le tableau de bord
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('zones'.tr),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.zones.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF1B5E20)),
                const SizedBox(height: 12),
                Text('loading'.tr, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.zones.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio:
                0.58, // Ajusté pour éviter les débordements (overflow)
          ),
          itemBuilder: (context, index) =>
              _construireCarteZone(controller.zones[index]),
        );
      }),
    );
  }

  Widget _construireCarteZone(dynamic zone) {
    return Obx(() {
      bool estEnAlerte = zone.humidity.value < 30;

      // Gestion du nom de la zone avec traduction
      String zoneName = zone.zoneNum.isNotEmpty
          ? '${'zone_label'.tr} ${zone.zoneNum}'
          : zone.name;

      return Card(
        elevation: estEnAlerte ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: estEnAlerte ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- ICÔNE D'ÉTAT ---
                    Icon(
                      estEnAlerte ? Icons.warning_amber_rounded : Icons.eco,
                      color: estEnAlerte ? Colors.red : Colors.green,
                      size: 26,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      zoneName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Badge d'alerte humidité
                    if (estEnAlerte)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'low_humidity_alert'.tr,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    const Divider(height: 8),

                    // --- DONNÉES CAPTEURS ---
                    _buildSensorRow(
                      Icons.opacity,
                      '${'hum_short'.tr}: ${zone.humidity.value.toStringAsFixed(1)}%',
                      Colors.blue,
                    ),
                    _buildSensorRow(
                      Icons.thermostat,
                      '${'temp_short'.tr}: ${zone.temperature.value.toStringAsFixed(1)}°C',
                      Colors.orange,
                    ),
                    _buildSensorRow(
                      Icons.science,
                      'pH: ${zone.ph.value.toStringAsFixed(1)}',
                      Colors.teal,
                    ),
                    _buildSensorRow(
                      Icons.bolt,
                      'EC: ${zone.ec.value.toInt()}',
                      Colors.purple,
                    ),

                    const SizedBox(height: 4),

                    // --- BADGES NPK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _npkBadge("N", zone.azote.value, Colors.redAccent),
                        _npkBadge(
                          "P",
                          zone.phosphore.value,
                          Colors.orangeAccent,
                        ),
                        _npkBadge("K", zone.potassium.value, Colors.blueAccent),
                      ],
                    ),

                    const Spacer(),

                    // --- BOUTON POMPE ---
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: zone.enabled.value,
                        onChanged: (val) => controller.basculerPompe(zone, val),
                        activeThumbColor: estEnAlerte
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                    Text(
                      zone.enabled.value ? 'running'.tr : 'stopped'.tr,
                      style: TextStyle(
                        color: zone.enabled.value ? Colors.blue : Colors.grey,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOUTON HISTORIQUE (Top Right) ---
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                icon: const Icon(
                  Icons.bar_chart,
                  color: Colors.blueGrey,
                  size: 18,
                ),
                onPressed: () => Get.to(
                  () => HistoryPage(zoneName: zoneName, zoneId: zone.id),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSensorRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _npkBadge(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        Text(
          "${value.toInt()}",
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
