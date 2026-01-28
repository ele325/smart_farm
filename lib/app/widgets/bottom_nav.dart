import 'package:flutter/material.dart';
import 'package:get/get.dart';
// 1. Importe bien ton RootController
import '../modules/root/root_controller.dart'; 

class BottomNav extends StatelessWidget {
  BottomNav({super.key});

  // 2. Cherche le RootController au lieu du DashboardController
  final controller = Get.find<RootController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BottomNavigationBar(
          // 3. Utilise currentIndex du RootController
          currentIndex: controller.currentIndex.value,
          // 4. Utilise la méthode changePage que nous avons créée dans le RootController
          onTap: controller.changePage, 
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