import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/routes.dart';

class SignupController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cinController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  var isPasswordHidden = true.obs;
  var isConfirmHidden = true.obs;
  var isLoading = false.obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirm() => isConfirmHidden.value = !isConfirmHidden.value;

  bool isPasswordValid(String password) {
    if (password.length < 8) return false;
    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasLetters && hasDigits && hasSpecial;
  }

  Future<void> signup() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String cin = cinController.text.trim();
    String pass = passwordController.text;
    String confirmPass = confirmPasswordController.text;

    // 1. Validations de base
    if (name.isEmpty || email.isEmpty || cin.isEmpty || pass.isEmpty) {
      Get.snackbar("erreur".tr, "veuillez_remplir_champs".tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (!isPasswordValid(pass)) {
      Get.snackbar("erreur".tr, "password_too_weak".tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (pass != confirmPass) {
      Get.snackbar("erreur".tr, "passwords_not_match".tr,
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // 2. Création de l'utilisateur dans Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 3. Sauvegarde des données (Nom, CIN) dans Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'fullName': name,
          'email': email,
          'cin': cin,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 4. Marquer comme connecté localement
        _storage.write('isLoggedIn', true);
        _storage.write('user_email', email);
        _storage.write('user_name', name);

        Get.snackbar("success".tr, "account_created".tr,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        
        // Aller vers le Dashboard
        Get.offAllNamed(Routes.dashboard);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Erreur d'inscription";
      if (e.code == 'email-already-in-use') msg = "Cet email est déjà utilisé";
      if (e.code == 'weak-password') msg = "Mot de passe trop faible";
      
      Get.snackbar("erreur".tr, msg, 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent);
    } catch (e) {
      Get.snackbar("erreur".tr, "Problème de connexion internet",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    cinController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}