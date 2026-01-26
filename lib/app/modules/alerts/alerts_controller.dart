import 'package:get/get.dart';

class AlertsController extends GetxController {
  final alerts = <String>[
    'Low soil humidity in Zone 2',
    'Pump overheating warning',
  ].obs;
}
