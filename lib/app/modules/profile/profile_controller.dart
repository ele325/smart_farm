import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/routes.dart';

class ProfileController extends GetxController {
  final _storage = GetStorage();
  final _picker = ImagePicker();

  var userName = ''.obs;
  var email = ''.obs;
  var units = 'metric'.obs;        // ✅ stocker la clé brute, pas le texte traduit
  var profileImagePath = ''.obs;
  var currentPlan = 'premium'.obs; // ✅ clé brute

  var billingHistory = [
    {'id': 'INV-001', 'date': '15/01/2026', 'service': 'annuel_sub', 'prix': '250 DT'},
    {'id': 'INV-002', 'date': '20/01/2026', 'service': 'growth_analysis', 'prix': '50 DT'},
  ].obs;

  @override
  void onInit() {
    super.onInit();
    userName.value = _storage.read('user_name') ?? 'Agriculteur';
    email.value = _storage.read('user_email') ?? 'contact@robocare.tn';
    units.value = _storage.read('user_units') ?? 'metric'; // ✅ clé brute
    profileImagePath.value = _storage.read('profile_pic') ?? '';
    currentPlan.value = _storage.read('user_plan') ?? 'premium';
  }

  void changeLanguage(String langCode) {
    Get.updateLocale(Locale(langCode));
    _storage.write('language_code', langCode);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        profileImagePath.value = image.path;
        _storage.write('profile_pic', image.path);
        if (Get.isBottomSheetOpen!) Get.back();
      }
    } catch (e) {
      Get.snackbar("erreur".tr, "access_denied".tr, backgroundColor: Colors.redAccent);
    }
  }
  // ✅ Ajouter cette méthode dans ProfileController
void deletePhoto() {
  profileImagePath.value = '';
  _storage.remove('profile_pic');
  if (Get.isBottomSheetOpen!) Get.back();
  Get.snackbar(
    "success".tr,
    "photo_deleted".tr,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
    icon: const Icon(Icons.check_circle, color: Colors.white),
  );
}

  void buyService(String serviceKey) {
    // ✅ serviceKey est la clé brute → on traduit ici
    Get.snackbar(
      "success".tr,
      "${"request_for".tr} '${serviceKey.tr}' ${"is_pending".tr}.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void downloadInvoice(String invoiceId) {
    Get.snackbar(
      "loading".tr,
      "${"invoice".tr} $invoiceId ${"downloaded".tr}.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

 void toggleUnits() {
  units.value = (units.value == 'metric') ? 'imperial' : 'metric';
  _storage.write('user_units', units.value);
}

  Future<void> makePhoneCall() async => await launchUrl(Uri.parse('tel:+21653140011'));
  Future<void> contactEmail() async =>
      await launchUrl(Uri(scheme: 'mailto', path: 'contact@robocare.tn'));

  void logout() {
    _storage.write('isLoggedIn', false);
    Get.offAllNamed(Routes.login);
  }
}