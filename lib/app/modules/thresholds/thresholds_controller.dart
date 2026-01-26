import 'package:get/get.dart';

class ThresholdsController extends GetxController {
  RxDouble minHumidity = 30.0.obs;
  RxDouble maxHumidity = 70.0.obs;
  RxInt duration = 15.obs;
}
