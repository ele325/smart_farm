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
        title: Text('dashboard'.tr),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDynamicHeader(),
          const SizedBox(height: 15),

          // Alerte Humidité
          Obx(() => (controller.soilMoisture.value < controller.minHumidityThreshold.value && controller.soilMoisture.value > 0)
              ? _buildAlertBanner() : const SizedBox.shrink()),

          _buildSectionTitle('STATUT PHYSIQUE'.tr),
          _buildStatusContainer(),
          const SizedBox(height: 20),

          _buildSectionTitle('ANALYSE NUTRIMENTS (NPK)'.tr),
          _buildNPKContainer(),
          const SizedBox(height: 25),

          _buildGraphHeader(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Obx(() => _infoRow('Humidité'.tr, '${controller.soilMoisture.value}%', Icons.water_drop, Colors.blue)),
          const Divider(),
          Obx(() => _infoRow('Température'.tr, '${controller.temperature.value}°C', Icons.thermostat, Colors.orange)),
          const Divider(),
          Obx(() => _infoRow('pH Sol'.tr, '${controller.phValue.value}', Icons.science, Colors.green)),
          const Divider(),
          Obx(() => _infoRow('Conductivité (EC)'.tr, '${controller.ecValue.value} µS/cm', Icons.bolt, Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildNPKContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => _nutrientCircle("N", controller.nitrogen.value, Colors.redAccent)),
          Obx(() => _nutrientCircle("P", controller.phosphorus.value, Colors.orangeAccent)),
          Obx(() => _nutrientCircle("K", controller.potassium.value, Colors.blueAccent)),
        ],
      ),
    );
  }

  Widget _nutrientCircle(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 50, height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        const SizedBox(height: 8),
        Text("${value.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text("mg/kg", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // --- Gardez vos autres widgets (_infoRow, _buildAlertBanner, etc.) identiques ---
  Widget _infoRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 15),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
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
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDynamicHeader() {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(controller.currentDate.value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(controller.currentTime.value, style: const TextStyle(color: Colors.grey)),
      ],
    ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
    );
  }

  Widget _buildGraphHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('analysis_24h'.tr),
        Row(children: [
          _legendItem("H%", Colors.blue),
          const SizedBox(width: 10),
          _legendItem("T°", Colors.orange),
        ]),
      ],
    );
  }

  Widget _buildGraphSection() {
    return Container(
      height: 200, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Obx(() => !controller.isDataLoaded.value 
        ? const Center(child: CircularProgressIndicator()) 
        : HistoryChart(humidityData: controller.humidityData.toList(), temperatureData: controller.temperatureData.toList())),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 10)),
    ]);
  }

  Widget _buildAlertBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text("Humidité critique !".tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent),
            onPressed: () => Get.toNamed(Routes.variateurControl),
            child: Text("IRRIGUER".tr),
          )
        ],
      ),
    );
  }
}