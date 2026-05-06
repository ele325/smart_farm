import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'package:smart_farm/app/widgets/history_chart.dart';
import 'package:smart_farm/app/routes/routes.dart';
import '../prediction_ai/prediction_page.dart';
import '../chat_ai/chat_page.dart';
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
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ✅ AJOUT DU BOUTON FLOTTANT POUR L'IA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => ChatPage()),
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.psychology, color: Colors.white), // Icône "Intelligence"
        label: Text("ia_assistant".tr, style: const TextStyle(color: Colors.white)),
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //_buildDynamicHeader(),
          const SizedBox(height: 15),

          // Alerte Humidité
          Obx(
            () =>
                (controller.soilMoisture.value <
                        controller.minHumidityThreshold.value &&
                    controller.soilMoisture.value > 0)
                ? _buildAlertBanner()
                : const SizedBox.shrink(),
          ),

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
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- STATUT PHYSIQUE ---
  Widget _buildStatusContainer() {
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
      ),
      child: Column(
        children: [
          Obx(
            () => _infoRow(
              'Humidité'.tr,
              '${controller.soilMoisture.value}%',
              Icons.water_drop,
              Colors.blue,
            ),
          ),
          const Divider(),
          Obx(
            () => _infoRow(
              'Température'.tr,
              '${controller.temperature.value}°C',
              Icons.thermostat,
              Colors.orange,
            ),
          ),
          const Divider(),
          Obx(
            () => _infoRow(
              'pH Sol'.tr,
              '${controller.phValue.value}',
              Icons.science,
              Colors.green,
            ),
          ),
          const Divider(),
          Obx(
            () => _infoRow(
              'Conductivité (EC)'.tr,
              '${controller.ecValue.value} µS/cm',
              Icons.bolt,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  // --- NPK CONTAINER ---
  Widget _buildNPKContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 20,
      ), // ✅ plus de padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(
            () => _nutrientCircle(
              "N".tr,
              controller.nitrogen.value,
              Colors.redAccent,
            ),
          ),
          Obx(
            () => _nutrientCircle(
              "P".tr,
              controller.phosphorus.value,
              Colors.orangeAccent,
            ),
          ),
          Obx(
            () => _nutrientCircle(
              "K".tr,
              controller.potassium.value,
              Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Cercles NPK agrandis
  Widget _nutrientCircle(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          width: 85,
          height: 85, // ✅ 70 → 85 pour une meilleure lisibilité
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 2,
            ), // ✅ bordure
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15, // ✅ 26 → 30
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "${value.toInt()}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ), // ✅ 18 → 20
        ),
        Text(
          "mg/kg".tr,
          style: const TextStyle(fontSize: 11, color: Colors.grey), // ✅ 10 → 11
        ),
      ],
    );
  }

  // --- INFO ROW ---
  Widget _infoRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  // --- ACCÈS RAPIDE ---
  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickItem(
            Icons.tune,
            "thresholds".tr,
            Colors.orange,
            () => Get.toNamed(
              Routes.thresholds,
              arguments: {
                'name': 'Zone',
                'id': 'zone1',
              },
            ),
          ),
          _quickItem(
            Icons.power,
            "pump".tr,
            Colors.blue,
            () => Get.toNamed(Routes.variateurControl),
          ),
          _quickItem(
            Icons.history,
            "history".tr,
            Colors.teal,
            () => Get.toNamed(Routes.history),
          ),
          _quickItem(
            Icons.trending_up,
            "prediction".tr,
            Colors.brown,
            () => Get.to(() => PredictionPage()),
          ),
        ],
      ),
    );
  }

  Widget _quickItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  // --- HEADER DATE/HEURE ---
  Widget _buildDynamicHeader() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.currentDate.value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            controller.currentTime.value,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- TITRE DE SECTION ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  // --- GRAPHE HEADER ---
  Widget _buildGraphHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('analysis_24h'.tr),
        Row(
          children: [
            _legendItem("H%", Colors.blue),
            const SizedBox(width: 10),
            _legendItem("T°", Colors.orange),
          ],
        ),
      ],
    );
  }

  // --- GRAPHE ---
  Widget _buildGraphSection() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Obx(
        () => !controller.isDataLoaded.value
            ? const Center(child: CircularProgressIndicator())
            : HistoryChart(
                humidityData: controller.humidityData.toList(),
                temperatureData: controller.temperatureData.toList(),
              ),
      ),
    );
  }

  Widget _legendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  // --- BANNIÈRE ALERTE ---
  Widget _buildAlertBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Humidité critique !".tr,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.redAccent,
            ),
            onPressed: () => Get.toNamed(Routes.variateurControl),
            child: Text("IRRIGUER".tr),
          ),
        ],
      ),
    );
  }
}
