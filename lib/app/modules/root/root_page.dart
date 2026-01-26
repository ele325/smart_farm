import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard/dashboard_controller.dart';
import '../dashboard/dashboard_page.dart';
import '../zones/zones_page.dart';
import '../alerts/alerts_page.dart';
import '../profile/profile_page.dart';
import '../../widgets/bottom_nav.dart';

class RootPage extends StatelessWidget {
  RootPage({super.key});

  final controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => WillPopScope(
        onWillPop: () async {
          if (controller.currentIndex.value != 0) {
            controller.currentIndex.value = 0;
            return false;
          }
          return true;
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
          bottomNavigationBar: BottomNav(),
        ),
      ),
    );
  }
}
