import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/profile_controller.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();
  final profileCtrl = Get.find<ProfileController>();

  void changeLanguage(String langCode) {
    Locale locale = Locale(langCode);
    Get.updateLocale(locale);
    _storage.write('language_code'.tr, langCode);
    
    // Ferme le dialogue si ouvert
    if (Get.isDialogOpen == true) Get.back();
    
    Get.snackbar(
      "language".tr, 
      "settings_updated".tr, // Utilisation d'une clé existante
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
    );
  }

  void toggleUnits() {
    profileCtrl.toggleUnits();
  }

  Future<void> contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto'.tr,
      path: 'support@smartfarm.tn'.tr,
      queryParameters: {'subject': 'Support SmartFarm PFE'.tr}
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      Get.snackbar("erreur".tr, "google_error".tr); // Réutilisation des clés d'erreur
    }
  }
}