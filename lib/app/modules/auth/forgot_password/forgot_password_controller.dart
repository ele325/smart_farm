import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  var isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // J'ai gardé ton nom : resetPassword
  Future<void> resetPassword() async {
    String email = emailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("erreur".tr, "veuillez_saisir_email_valide".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);

      Get.snackbar("success".tr, "email_sent_success".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);

      Future.delayed(const Duration(seconds: 2), () => Get.back());
    } on FirebaseAuthException catch (e) {
      String message = (e.code == 'user-not-found') ? "user_not_found".tr : "erreur_interne".tr;
      Get.snackbar("erreur".tr, message, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}