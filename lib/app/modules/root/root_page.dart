import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'root_controller.dart'; // Import du nouveau contrôleur
import '../dashboard/dashboard_page.dart';
import '../zones/zones_page.dart';
import '../alerts/alerts_page.dart';
import '../profile/profile_page.dart';

class RootPage extends StatelessWidget {
  RootPage({super.key});

  // On injecte le RootController ici
  final controller = Get.put(RootController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope( // Note: WillPopScope est déprécié, on utilise PopScope
        canPop: controller.currentIndex.value == 0,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (controller.currentIndex.value != 0) {
            controller.currentIndex.value = 0;
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: [
              DashboardPage(),
              ZonesPage(),
              AlertsPage(),
              ProfilePage(),
            ],
          ),
          // N'oublie pas de passer l'index au widget BottomNav
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Tableau de bord'),
              BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Zones'),
              BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alertes'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}