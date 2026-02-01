import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'zones_controller.dart';

class ZonesPage extends StatelessWidget {
  ZonesPage({super.key});
  final ZonesController controller = Get.put(ZonesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('zones_management'.tr),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.zones.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.green));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.zones.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.8, // Ajusté pour donner plus de place verticale
          ),
          itemBuilder: (context, index) => _construireCarteZone(controller.zones[index]),
        );
      }),
    );
  }

  Widget _construireCarteZone(Zone zone) {
    return Obx(() {
      bool estEnAlerte = zone.humidity < 30;
      return Card(
        elevation: estEnAlerte ? 6 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: estEnAlerte ? Colors.red : Colors.transparent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(
                estEnAlerte ? Icons.warning_amber_rounded : Icons.water_drop,
                color: estEnAlerte ? Colors.red : (zone.enabled.value ? Colors.blue : Colors.grey),
                size: 35,
              ),
              const SizedBox(height: 5),
              Text(zone.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text("${'soil'.tr}: ${zone.humidity}%", style: TextStyle(color: estEnAlerte ? Colors.red : Colors.black54, fontSize: 12)),
              const Spacer(),
              Switch(
                value: zone.enabled.value,
                onChanged: (val) => controller.basculerPompe(zone, val),
                activeColor: estEnAlerte ? Colors.red : Colors.blue,
              ),
              FittedBox(
                child: Text(zone.enabled.value ? 'running'.tr : 'stopped'.tr, 
                style: TextStyle(color: zone.enabled.value ? Colors.blue : Colors.grey, fontSize: 10)),
              ),
            ],
          ),
        ),
      );
    });
  }
}