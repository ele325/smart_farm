import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'alerts_controller.dart';

class AlertsPage extends StatelessWidget {
  final controller = Get.put(AlertsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('alerts'.tr),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.alerts.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(controller.alerts[i]),
          ),
        ),
      ),
    );
  }
}
