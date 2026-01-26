import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  // Contrôleurs de saisie
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cinController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isConfirmHidden = true.obs;
  var isLoading = false.obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirm() => isConfirmHidden.value = !isConfirmHidden.value;

  // Fonction de validation du mot de passe (8 caractères, Lettres, Chiffres, Symboles)
  bool isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasLetters && hasDigits && hasSpecial;
  }

  void signup() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String cin = cinController.text.trim();
    String pass = passwordController.text;
    String confirmPass = confirmPasswordController.text;

    // 1. Vérifier si les champs sont vides
    if (name.isEmpty || email.isEmpty || cin.isEmpty || pass.isEmpty) {
      Get.snackbar("erreur".tr, "veuillez_remplir_champs".tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // 2. Vérifier la force du mot de passe
    if (!isPasswordValid(pass)) {
      Get.snackbar("erreur".tr, "password_too_weak".tr, // "8 caractères minimum avec lettres, chiffres et symboles"
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // 3. Vérifier la confirmation
    if (pass != confirmPass) {
      Get.snackbar("erreur".tr, "passwords_not_match".tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Si tout est OK
    Get.snackbar("success".tr, "account_created".tr,
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    
    // Retourner au login
    Get.back();
  }
}