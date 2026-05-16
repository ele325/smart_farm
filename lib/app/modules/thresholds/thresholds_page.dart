import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'thresholds_controller.dart';
import '../zones/zones_controller.dart';

class ThresholdsPage extends StatelessWidget {
  final String zoneId;
  final String zoneName;

  ThresholdsPage({super.key, required this.zoneId, required this.zoneName});

  late final ThresholdsController controller = Get.put(
    ThresholdsController(zoneId: zoneId, zoneName: zoneName),
    tag: zoneId,
  );

  static const Color humidityColor = Color(0xFF2196F3);
  static const Color temperatureColor = Color(0xFFFF7043);
  static const Color phColor = Color(0xFF26A69A);
  static const Color ecColor = Color(0xFFAB47BC);
  static const Color nColor = Color(0xFFEF5350);
  static const Color pColor = Color(0xFFFFB74D);
  static const Color kColor = Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          "${"irrigation_thresholds".tr} — $zoneName",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Les seuils sont configurés par les ingénieurs agricoles pour garantir une irrigation optimale.",
                      style: TextStyle(fontSize: 12, color: Color(0xFF0D47A1), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => Text(
                controller.plantType.value.isEmpty
                    ? "Plante: $zoneName"
                    : "Plante: ${controller.plantType.value}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Obx(
              () => controller.hasCustomThresholds.value
                  ? Column(
                      children: [
                        _buildRangeEditor(
                          title: 'Humidité (%)',
                          keyName: 'humidity',
                          color: humidityColor,
                          icon: Icons.opacity,
                        ),
                        const SizedBox(height: 10),
                        _buildRangeEditor(
                          title: 'Température (°C)',
                          keyName: 'temperature',
                          color: temperatureColor,
                          icon: Icons.thermostat,
                        ),
                        const SizedBox(height: 10),
                        _buildRangeEditor(
                          title: 'pH',
                          keyName: 'ph',
                          color: phColor,
                          icon: Icons.science,
                        ),
                        const SizedBox(height: 10),
                        _buildRangeEditor(
                          title: 'EC',
                          keyName: 'ec',
                          color: ecColor,
                          icon: Icons.bolt,
                        ),
                        const SizedBox(height: 10),
                        _buildRangeEditor(
                          title: 'Azote (N)',
                          keyName: 'n',
                          color: nColor,
                          icon: Icons.grass,
                        ),
                        const SizedBox(height: 10),
                        _buildRangeEditor(
                          title: 'Phosphore (P)',
                          keyName: 'p',
                          color: pColor,
                          icon: Icons.spa,
                        ),
                        const SizedBox(height: 10),
                        _buildRangeEditor(
                          title: 'Potassium (K)',
                          keyName: 'k',
                          color: kColor,
                          icon: Icons.local_florist,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 18),
            _buildDurationCard(),
            // ✅ BOUTON DÉMARRER avec compte à rebours — lit depuis ZonesController (permanent)
            Builder(builder: (context) {
              final zonesCtrl = Get.isRegistered<ZonesController>()
                  ? Get.find<ZonesController>()
                  : null;
              final zone = zonesCtrl?.getZone(zoneId);

              if (zone == null) {
                return Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.startTimedIrrigation(),
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        "${'start'.tr} (${controller.duration.value} min)",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                });
              }

              return Obx(() {
                final irrigating = zone.isIrrigating.value;
                final remaining = zone.remainingSeconds.value;
                final mins = remaining ~/ 60;
                final secs = remaining % 60;
                final label = irrigating
                    ? "⏱ ${'irrigating'.tr}  $mins:${secs.toString().padLeft(2, '0')}"
                    : "${'start'.tr} (${controller.duration.value} min)";
                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: irrigating ? Colors.red[700] : Colors.blue[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : (irrigating 
                            ? () => controller.stopTimedIrrigation() 
                            : () => controller.startTimedIrrigation()),
                    icon: Icon(
                      irrigating ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              });
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Color(0xFF1B5E20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "irrigation_duration".tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    "duration_help".tr, // "Cette durée sera utilisée lors du démarrage manuel."
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 45,
                child: TextField(
                  controller: controller.durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "min",
                    suffixText: "min",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) {
                    int? minutes = int.tryParse(val);
                    if (minutes != null && minutes > 0) {
                      controller.duration.value = minutes;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildRangeEditor({
    required String title,
    required String keyName,
    required Color color,
    required IconData icon,
  }) {
    final range = controller.thresholds[keyName]!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStepper(
                  label: 'Min',
                  value: range.min,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStepper(
                  label: 'Max',
                  value: range.max,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepper({
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

}