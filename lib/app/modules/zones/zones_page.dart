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
            childAspectRatio: 0.52,
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
      final bool enArrosage = zone.irrigationStatus.value == 'STARTED' || zone.enabled.value;

      final String zoneName = zone.plantType.value.isNotEmpty
          ? zone.plantType.value
          : zone.zoneNum.isNotEmpty
              ? '${'zone_label'.tr} ${zone.zoneNum}'
              : zone.name;

      return Card(
        elevation: enArrosage ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: enArrosage ? Colors.blue : (estEnAlerte ? Colors.red : Colors.transparent),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── HEADER ──
              Row(
                children: [
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      children: [
                        _buildStatusIcon(enArrosage, estEnAlerte),
                        const SizedBox(height: 2),
                        Text(
                          zoneName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildHistoryButton(zoneName, zone.id),
                ],
              ),

              const Divider(height: 8),

              // ── SENSORS ──
              _buildSensorRow(Icons.opacity, '${'hum_short'.tr}: ${zone.humidity.value.toStringAsFixed(1)}%', Colors.blue),
              _buildSensorRow(Icons.thermostat, '${'temp_short'.tr}: ${zone.temperature.value.toStringAsFixed(1)}°C', Colors.orange),
              _buildSensorRow(Icons.science, 'pH: ${zone.ph.value.toStringAsFixed(1)}', Colors.teal),
              _buildSensorRow(Icons.bolt, 'EC: ${zone.ec.value.toInt()}', Colors.purple),

              const SizedBox(height: 4),

              // ── NPK ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _npkBadge('N', zone.azote.value, Colors.redAccent),
                  _npkBadge('P', zone.phosphore.value, Colors.orangeAccent),
                  _npkBadge('K', zone.potassium.value, Colors.blueAccent),
                ],
              ),

              const Spacer(),

              // ── SEUILS BUTTON ──
              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[800],
                    side: BorderSide(color: Colors.green[800]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.tune, size: 14),
                  label: Text('thresholds'.tr, style: const TextStyle(fontSize: 10)),
                  onPressed: () => Get.to(() => ThresholdsPage(zoneName: zoneName, zoneId: zone.id)),
                ),
              ),

              const SizedBox(height: 4),

              // ── SWITCH ──
              Transform.scale(
                scale: 0.78,
                child: Switch(
                  value: enArrosage,
                  onChanged: (val) => controller.basculerPompe(zone, val),
                  activeThumbColor: Colors.blue,
                ),
              ),

              Text(
                enArrosage ? 'running'.tr : 'stopped'.tr,
                style: TextStyle(
                  color: enArrosage ? Colors.blue : Colors.grey,
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

  Widget _buildStatusIcon(bool enArrosage, bool estEnAlerte) {
    if (enArrosage) {
      return const _PulsingIcon(icon: Icons.water_drop, color: Colors.blue);
    }
    return Icon(
      estEnAlerte ? Icons.warning_amber_rounded : Icons.eco,
      color: estEnAlerte ? Colors.red : Colors.green,
      size: 26,
    );
  }

  Widget _buildHistoryButton(String zoneName, String zoneId) {
    return SizedBox(
      width: 28, height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.bar_chart, color: Colors.blueGrey, size: 20),
        onPressed: () => Get.to(() => HistoryPage(zoneName: zoneName, zoneId: zoneId)),
      ),
    );
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
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
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
          width: 20, height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
        Text(value.toInt().toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _PulsingIcon({required this.icon, required this.color});
  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.2).animate(_controller),
      child: Icon(widget.icon, color: widget.color, size: 26),
    );
  }
}