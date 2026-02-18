import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/profile_controller.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();
  final profileCtrl = Get.find<ProfileController>();

  void changeLanguage(String langCode) {
    Get.updateLocale(Locale(langCode));
    _storage.write('language_code', langCode); // ✅ clé brute, pas .tr

    if (Get.isDialogOpen == true) Get.back();

    Get.snackbar(
      "language".tr,
      "settings_updated".tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void toggleUnits() {
    profileCtrl.toggleUnits(); // ✅ délégation au ProfileController
  }

  Future<void> makePhoneCall() async {
    final Uri uri = Uri.parse('tel:+21653140011');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("erreur".tr, "access_denied".tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> contactEmail() async {
    final Uri uri = Uri(
      scheme: 'mailto',           // ✅ pas de .tr sur le scheme
      path: 'contact@robocare.tn',
      queryParameters: {'subject': 'Support RoboCare'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("erreur".tr, "google_error".tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}