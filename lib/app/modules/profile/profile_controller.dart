import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/routes.dart';

class ProfileController extends GetxController {
  final userName = 'Farmer Ahmed'.obs;
  final email = 'farmer@smartfarm.com'.obs;
  final plan = 'Premium'.obs;
  final _storage = GetStorage();

  void changeLanguage(String langCode) {
    if (langCode == 'ar') {
      Get.updateLocale(const Locale('ar'));
    } else if (langCode == 'fr') {
      Get.updateLocale(const Locale('fr'));
    } else {
      Get.updateLocale(const Locale('en'));
    }
    _storage.write('language_code', langCode);
  }

  void logout() {
    _storage.write('isLoggedIn', false);
    _storage.remove('user_email');
    _storage.remove('user_name');
    Get.offAllNamed(Routes.login);
  }
}
