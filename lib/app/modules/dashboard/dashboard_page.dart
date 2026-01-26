import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:smart_farm/app/widgets/info_card.dart';
import 'package:smart_farm/app/widgets/section_title.dart';
import 'dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('dashboard'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'overview'.tr,
            child: Column(
              children: [
                InfoCard(
                  title: 'soil'.tr,
                  value: '45%',
                  icon: Icons.water_drop,
                ),
                InfoCard(
                  title: 'temperature'.tr,
                  value: '28°C',
                  icon: Icons.thermostat,
                ),
                InfoCard(title: 'pump'.tr, value: 'ON', icon: Icons.power),
                InfoCard(
                  title: 'battery'.tr,
                  value: '80%',
                  icon: Icons.battery_full,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Quick Access',
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _QuickAction(
                  icon: Icons.tune,
                  label: 'Thresholds',
                  onTap: () => Get.toNamed('/thresholds'),
                ),
                _QuickAction(
                  icon: Icons.power,
                  label: 'Pump',
                  onTap: () => Get.toNamed('/pump'),
                ),
                _QuickAction(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () => Get.toNamed('/history'),
                ),
                _QuickAction(
                  icon: Icons.map,
                  label: 'Map',
                  onTap: () => Get.toNamed('/map'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(icon, color: Colors.white),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
