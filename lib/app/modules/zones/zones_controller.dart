import 'package:get/get.dart';

class Zone {
  final String name;
  RxBool enabled;
  final int humidity;

  Zone(this.name, bool status, this.humidity)
      : enabled = status.obs;
}

class ZonesController extends GetxController {
  final zones = List.generate(
    8,
    (i) => Zone('Zone ${i + 1}', i % 2 == 0, 30 + i),
  ).obs;
}
