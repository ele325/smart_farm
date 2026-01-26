import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/routes.dart';

class LoginController extends GetxController {
 final _storage = GetStorage();
  
  // Correction pour la version 7.2.0+
  // On utilise l'instance configurée avec des paramètres nommés
 final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "erreur".tr,
        "veuillez_remplir_champs".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    _storage.write('isLoggedIn', true);
    _storage.write('user_email', email);
    Get.offAllNamed(Routes.dashboard);
  }

  // --- LOGIQUE GOOGLE SIGN-IN RÉELLE ---
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      
      // La méthode signIn() fonctionnera maintenant car l'objet est bien initialisé
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        _storage.write('isLoggedIn', true);
        _storage.write('user_email', googleUser.email);
        _storage.write('user_name', googleUser.displayName);
        _storage.write('user_photo', googleUser.photoUrl);

        Get.snackbar(
          "success".tr,
          "welcome".tr + " ${googleUser.displayName}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(Routes.dashboard);
      }
    } catch (error) {
      print("Erreur Google Sign-In : $error");
      Get.snackbar(
        "erreur".tr,
        "google_error".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}