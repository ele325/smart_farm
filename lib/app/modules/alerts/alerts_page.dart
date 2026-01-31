import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'alerts_controller.dart';
// Importe tes widgets personnalisés ici
import '../../widgets/info_card.dart'; 
import '../../widgets/section_title.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AlertsController());

    return Scaffold(
      appBar: AppBar(title: const Text("Alertes & Seuils"), backgroundColor: Colors.red[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. CONFIGURATION DES NOTIFICATIONS
            SectionCard(
              title: "Paramètres",
              child: Obx(() => SwitchListTile(
                title: const Text("Notifications Push"),
                subtitle: const Text("Recevoir des alertes sur le téléphone"),
                value: controller.isPushEnabled.value,
                activeColor: Colors.green,
                onChanged: controller.toggleNotifications,
              )),
            ),
            const SizedBox(height: 20),

            // 2. CONFIGURATION DES SEUILS (Sliders)
            SectionCard(
              title: "Configuration des Seuils",
              child: Obx(() => Column(
                children: [
                  _buildSlider("Température Max (${controller.tempThreshold.value.round()}°C)", 
                    controller.tempThreshold.value, 10, 50, (v) => controller.updateThreshold('temp', v)),
                  _buildSlider("Humidité Min (${controller.humidityThreshold.value.round()}%)", 
                    controller.humidityThreshold.value, 0, 100, (v) => controller.updateThreshold('hum', v)),
                ],
              )),
            ),
            const SizedBox(height: 20),

            // 3. LISTE DES ALERTES ACTIVES / HISTORIQUE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Historique des Alertes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Obx(() => Column(
              children: controller.activeAlerts.map((alert) {
                return InfoCard(
                  title: "${alert['title']} - ${alert['zone']}",
                  value: alert['time']!,
                  icon: alert['level'] == 'Critique' ? Icons.error : Icons.warning,
                  statusColor: alert['level'] == 'Critique' ? Colors.red : Colors.orange,
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 40,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      ],
    );
  }
}