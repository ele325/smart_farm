import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/root/root_controller.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final RootController controller = Get.find<RootController>();

    // ✅ Obx garantit la reconstruction à chaque changement de langue
    return Obx(() {
      // Lecture de locale pour forcer le rebuild sur changement de langue
      final _ = Get.locale;

      return BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B5E20),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: 'dashboard'.tr, // ✅ clé existante dans AppTranslations
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.water_drop),
            label: 'zones'.tr, // ✅
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: 'alerts'.tr, // ✅
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr, // ✅
          ),
        ],
      );
    });
  }
}
