import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zones_controller.dart';
import '../history/history_page.dart';
import '../thresholds/thresholds_page.dart';

class ZonesPage extends StatelessWidget {
  ZonesPage({super.key});

  final ZonesController controller = Get.put(
    ZonesController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'loading'.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
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
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, index) {
            return _construireCarteZone(controller.zones[index]);
          },
        );
      }),
    );
  }

  Widget _construireCarteZone(dynamic zone) {
    return Obx(() {
      final bool estEnAlerte = zone.humidity.value < 30;

      final String zoneName = zone.plantType.value.isNotEmpty
          ? zone.plantType.value
          : zone.zoneNum.isNotEmpty
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER : icône + nom zone + bouton historique ──
              Row(
                children: [
                  const SizedBox(width: 28),

                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          estEnAlerte
                              ? Icons.warning_amber_rounded
                              : Icons.eco,
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
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // ── BOUTON HISTORIQUE TOUJOURS VISIBLE ──
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Historique',
                      icon: const Icon(
                        Icons.bar_chart,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                      onPressed: () => Get.to(
                        () => HistoryPage(
                          zoneName: zoneName,
                          zoneId: zone.id,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (estEnAlerte)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _npkBadge('N', zone.azote.value, Colors.redAccent),
                  _npkBadge('P', zone.phosphore.value, Colors.orangeAccent),
                  _npkBadge('K', zone.potassium.value, Colors.blueAccent),
                ],
              ),

              const Spacer(),

              // ── BOUTON SEUILS ──
              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green[800]!),
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.tune, size: 14),
                  label: Text(
                    'thresholds'.tr,
                    style: const TextStyle(fontSize: 10),
                  ),
                  onPressed: () => Get.to(
                    () => ThresholdsPage(
                      zoneName: zoneName,
                      zoneId: zone.id,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // ── SWITCH POMPE / VANNE ──
              Transform.scale(
                scale: 0.78,
                child: Switch(
                  value: zone.enabled.value,
                  onChanged: (val) => controller.basculerPompe(zone, val),
                  activeThumbColor: estEnAlerte ? Colors.red : Colors.blue,
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          value.toInt().toString(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}