import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/dashboard/dashboard_controller.dart';

class BottomNav extends StatelessWidget {
  BottomNav({super.key});

  final controller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: 'dashboard'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.water_drop),
              label: 'zones'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.warning),
              label: 'alerts'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: 'profile'.tr,
            ),
          ],
        ));
  }
}
