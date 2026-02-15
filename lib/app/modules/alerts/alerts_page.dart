import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'alerts_controller.dart';
import '../../widgets/info_card.dart';
import '../../widgets/section_card.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation de Get.find si déjà injecté ou Get.put
    final controller = Get.put(AlertsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('alerts_system'.tr),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATISTIQUES ---
            Obx(() => Row(
              children: [
                _buildStatItem(
                  controller.alerts.where((a) => a['level'] == 'critique').length.toString(), 
                  "critique".tr, Colors.red
                ),
                const SizedBox(width: 10),
                _buildStatItem(
                  controller.alerts.where((a) => a['level'] == 'warning').length.toString(), 
                  "warning".tr, Colors.orange
                ),
                const SizedBox(width: 10),
                _buildStatItem(
                  controller.alerts.length.toString(), 
                  "total".tr, Colors.blue
                ),
              ],
            )),
            const SizedBox(height: 20),

            SectionCard(
              title: "preferences".tr,
              child: Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("push_notifications".tr),
                subtitle: Text("real_time_alerts_desc".tr),
                value: controller.isPushEnabled.value,
                activeColor: Colors.red[700],
                onChanged: controller.toggleNotifications,
              )),
            ),
            
            const SizedBox(height: 25),
            Text("latest_alerts".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // --- LISTE RÉACTIVE ---
            Obx(() {
              if (controller.alerts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("no_alerts".tr, style: const TextStyle(color: Colors.grey)),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.alerts.length,
                itemBuilder: (context, index) {
                  final alert = controller.alerts[index];
                  final bool isCritique = alert['level'] == 'critique';        
                  
                  return InfoCard(
                    title: alert['title']!,
                    value: "${alert['msg']} (${alert['time']})",
                    icon: isCritique ? Icons.report_problem : Icons.warning_amber_rounded,
                    statusColor: isCritique ? Colors.red : Colors.orange,
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}