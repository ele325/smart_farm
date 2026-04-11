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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "${"irrigation_thresholds".tr} — $zoneName",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "thresholds_desc".tr,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // --- SEUIL MINIMUM ---
            Obx(
              () => _buildThresholdCard(
                title: "min_humidity".tr,
                subtitle:
                    "${"min_hum_desc".tr} ${controller.minHumidity.value.round()}%",
                value: controller.minHumidity.value,
                color: Colors.orange,
                icon: Icons.water_drop_outlined,
                onChanged: (val) {
                  if (val < (controller.maxHumidity.value - 5)) {
                    controller.minHumidity.value = val;
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- SEUIL MAXIMUM ---
            Obx(
              () => _buildThresholdCard(
                title: "max_humidity".tr,
                subtitle:
                    "${"max_hum_desc".tr} ${controller.maxHumidity.value.round()}%",
                value: controller.maxHumidity.value,
                color: Colors.blue,
                icon: Icons.opacity,
                onChanged: (val) {
                  if (val > (controller.minHumidity.value + 5)) {
                    controller.maxHumidity.value = val;
                  }
                },
              ),
            ),

            const SizedBox(height: 20),
            _buildDurationCard(),
            const SizedBox(height: 40),

            // --- BOUTON SAUVEGARDE ---
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdCard({
    required String title,
    required String subtitle,
    required double value,
    required Color color,
    required IconData icon,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                "${value.round()}%",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "irrigation_duration".tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
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