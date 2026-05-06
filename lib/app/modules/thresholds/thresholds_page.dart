import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'thresholds_controller.dart';

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
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "thresholds_desc".tr,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B949E),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 30),
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
            Obx(
              () => controller.hasCustomThresholds.value
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFFD591)),
                      ),
                      child: const Text(
                        "Cette zone n'a pas encore de seuils réels configurés par l'admin.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8C6D1F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 14),

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
            Obx(
              () => controller.hasCustomThresholds.value
                  ? _buildDurationCard()
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 30),

            // --- BOUTON SAUVEGARDE ---
            Obx(
              () => controller.hasCustomThresholds.value
                  ? SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 1.5,
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : () async {
                                bool success = await controller.saveSettings();
                                if (success) _showSuccessMessage();
                              },
                        icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.white),
                        label: Text(
                          controller.isLoading.value
                              ? "saving...".tr
                              : "save_settings".tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard() {
    return Obx(
      () => Container(
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
              child: Text(
                "irrigation_duration".tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            DropdownButton<int>(
              value: controller.duration.value,
              items: [5, 10, 15, 30]
                  .map(
                    (val) => DropdownMenuItem(
                      value: val,
                      child: Text("$val min"),
                    ),
                  )
                  .toList(),
              onChanged: (val) => controller.duration.value = val!,
            ),
          ],
        ),
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
                  onMinus: () => controller.setThresholdMin(keyName, range.min - 1),
                  onPlus: () => controller.setThresholdMin(keyName, range.min + 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStepper(
                  label: 'Max',
                  value: range.max,
                  color: color,
                  onMinus: () => controller.setThresholdMax(keyName, range.max - 1),
                  onPlus: () => controller.setThresholdMax(keyName, range.max + 1),
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
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _stepActionIcon(
                  icon: Icons.remove_circle_outline,
                  color: color,
                  onTap: onMinus,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _stepActionIcon(
                  icon: Icons.add_circle_outline,
                  color: color,
                  onTap: onPlus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 22,
        height: 22,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showSuccessMessage() {
    Get.snackbar(
      "config_updated".tr,
      "pump_logic_desc".tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[800],
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
}