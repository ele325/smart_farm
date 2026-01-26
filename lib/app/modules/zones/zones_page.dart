import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'zones_controller.dart';

class ZonesPage extends StatelessWidget {
  final controller = Get.put(ZonesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('zones'.tr),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.zones.length,
          itemBuilder: (_, i) {
            final zone = controller.zones[i];
            return Card(
              child: ListTile(
                title: Text(zone.name),
                subtitle: Text('${'humidity'.tr}: ${zone.humidity}%'),
                trailing: Switch(
                  value: zone.enabled.value,
                  onChanged: (v) => zone.enabled.value = v,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
