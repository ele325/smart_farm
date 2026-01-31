import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pump_controller.dart';

class PumpPage extends StatelessWidget {
  PumpPage({super.key});
  final controller = Get.put(PumpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pump Control')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => Column(
              children: [
                SwitchListTile(
                  title: const Text('Pump ON/OFF'),
                  value: controller.isOn.value,
                  onChanged: (v) => controller.isOn.value = v,
                ),
                Text('Frequency: ${controller.frequency.value.toInt()} Hz'),
                Slider(
                  min: 0,
                  max: 60,
                  value: controller.frequency.value,
                  onChanged: (v) => controller.frequency.value = v,
                ),
              ],
            )),
      ),
    );
  }
}
