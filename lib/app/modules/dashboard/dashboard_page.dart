import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'package:smart_farm/app/widgets/history_chart.dart';
import 'package:smart_farm/app/routes/routes.dart'; 

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Tableau de bord'.tr),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDynamicHeader(),
          const SizedBox(height: 20),
          _buildSectionTitle('STATUT GÉNÉRAL'.tr),
          _buildStatusContainer(),
          const SizedBox(height: 25),
          _buildGraphHeader(),
          const SizedBox(height: 10),
          _buildGraphSection(),
          const SizedBox(height: 25),
          _buildSectionTitle('quick_access'.tr),
          _buildQuickAccess(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _infoRow('Humidité du sol'.tr, '${controller.soilMoisture.value}%', Icons.water_drop, Colors.blue),
          const Divider(height: 1),
          _infoRow('temperature'.tr, '${controller.temperature.value}°C', Icons.thermostat, Colors.orange),
          const Divider(height: 1),
          _infoRow('pH du sol'.tr, '${controller.phValue.value}', Icons.science, Colors.green),
          const Divider(height: 1),
          
          // SEULE CETTE LIGNE EST RÉACTIVE POUR ÉVITER DE CASSER L'ECRAN
          Obx(() => _infoRow(
            'État de la pompe'.tr, 
            controller.isPumpOn.value ? 'ON'.tr : 'OFF'.tr, 
            Icons.power, 
            controller.isPumpOn.value ? Colors.green : Colors.grey,
          )),
          
          const Divider(height: 1),
          _infoRow('battery'.tr, '${controller.batteryLevel.value}%', Icons.battery_full, Colors.green[700]!),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15), // Espace aéré
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.w500))
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  // --- LES AUTRES SECTIONS (DESIGN ORIGINAL) ---

  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickItem(Icons.tune, "thresholds".tr, Colors.orange, () => Get.toNamed(Routes.thresholds)),
          _quickItem(Icons.power, "pump".tr, Colors.blue, () => Get.toNamed(Routes.variateurControl)),
          _quickItem(Icons.history, "history".tr, Colors.teal, () => Get.toNamed(Routes.history)),
          _quickItem(Icons.map, "map".tr, Colors.brown, () => Get.toNamed(Routes.map)),
        ],
      ),
    );
  }

  Widget _quickItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
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

  Widget _buildGraphHeader() {
    return Row(
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
    );
  }

  Widget _buildGraphSection() {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
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