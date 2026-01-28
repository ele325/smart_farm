import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'package:smart_farm/app/widgets/history_chart.dart';
// Importez vos routes si nécessaire, ou utilisez les noms de routes directement
import 'package:smart_farm/app/routes/routes.dart'; 

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title:  Text('Tableau de bord'.tr),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchSensorData(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDynamicHeader(),
          const SizedBox(height: 20),

          _buildSectionTitle('STATUT GÉNÉRAL'.tr),
          _buildStatusContainer(),
          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('analysis_24h'.tr),
              Row(
                children: [
                  _legendItem("H%", Colors.blue),
                  const SizedBox(width: 10),
                  _legendItem("T°C", Colors.orange),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGraphSection(),
          
          const SizedBox(height: 25),

          // --- QUICK ACCESS SOUS LA COURBE AVEC NAVIGATION ---
          _buildSectionTitle('quick_access'.tr),
          _buildQuickAccess(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- NAVIGATION CONFIGURÉE ICI ---
  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Navigation vers la page des Seuils
          _quickItem(Icons.tune, "thresholds".tr, Colors.orange, () {
            Get.toNamed(Routes.thresholds); 
          }),
          // Action sur la pompe (Reste sur la page mais change l'état)
          _quickItem(Icons.power, "pump".tr, Colors.blue, () {
            controller.togglePump();
          }),
          // Navigation vers l'Historique
          _quickItem(Icons.history, "history".tr, Colors.teal, () {
            Get.toNamed(Routes.history);
          }),
          // Navigation vers la Carte
          _quickItem(Icons.map, "map".tr, Colors.brown, () {
            Get.toNamed(Routes.map);
          }),
        ],
      ),
    );
  }

  Widget _buildStatusContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Obx(() => Column(
        children: [
          _infoRow('Humidité du sol'.tr, '${controller.soilMoisture.value}%', Icons.water_drop, Colors.blue),
          const Divider(height: 1),
          _infoRow('temperature'.tr, '${controller.temperature.value}°C', Icons.thermostat, Colors.orange),
          const Divider(height: 1),
          _infoRow('pH du sol'.tr, '${controller.phValue.value}', Icons.science, Colors.green),
          const Divider(height: 1),
          _infoRow(
            'État de la pompe'.tr, 
            controller.isPumpOn.value ? 'ON'.tr : 'OFF'.tr, 
            Icons.power, 
            controller.isPumpOn.value ? Colors.green : Colors.grey
          ),
          const Divider(height: 1),
          _infoRow('battery'.tr, '${controller.batteryLevel.value}%', Icons.battery_full, Colors.green[700]!),
        ],
      )),
    );
  }

  Widget _buildGraphSection() {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Obx(() {
        if (!controller.isDataLoaded.value) return const Center(child: CircularProgressIndicator());
        return HistoryChart(
          humidityData: controller.humidityData.toList(),
          temperatureData: controller.temperatureData.toList(),
        );
      }),
    );
  }

  Widget _infoRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 14))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _quickItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell( // Utilisation de InkWell pour l'effet visuel au clic
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicHeader() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(controller.currentDate.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(controller.currentTime.value, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ],
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}