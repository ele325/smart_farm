import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'thresholds_controller.dart';

class ThresholdsPage extends StatelessWidget {
  final controller = Get.put(ThresholdsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation Thresholds')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              children: [
                Text('Min Humidity: ${controller.minHumidity.value}%'),
                Slider(
                  min: 0,
                  max: 100,
                  value: controller.minHumidity.value,
                  onChanged: (v) => controller.minHumidity.value = v,
                ),
                Text('Max Humidity: ${controller.maxHumidity.value}%'),
                Slider(
                  min: 0,
                  max: 100,
                  value: controller.maxHumidity.value,
                  onChanged: (v) => controller.maxHumidity.value = v,
                ),
              ],
            )),
      ),
    );
  }
}
