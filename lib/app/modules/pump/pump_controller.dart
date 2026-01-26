import 'package:get/get.dart';

class PumpController extends GetxController {
  RxBool isOn = false.obs;
  RxDouble frequency = 30.0.obs;
}
