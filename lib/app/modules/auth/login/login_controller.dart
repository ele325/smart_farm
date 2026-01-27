import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/routes.dart';

class LoginController extends GetxController {
  final _storage = GetStorage();
  final _auth = FirebaseAuth.instance;
  
  // Configuration Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  // --- NOUVEAU : Variable pour "Se souvenir de moi" ---
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Charger les identifiants sauvegardés au démarrage
    rememberMe.value = _storage.read('remember_me') ?? false;
    if (rememberMe.value) {
      emailController.text = _storage.read('saved_email') ?? "";
      passwordController.text = _storage.read('saved_password') ?? "";
    }
  }

  // --- NOUVEAU : Méthode pour basculer la case à cocher ---
  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // --- CONNEXION CLASSIQUE EMAIL/PASSWORD ---
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("error".tr, "fill_all_fields".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // --- LOGIQUE DE SAUVEGARDE PERSISTANTE ---
        if (rememberMe.value) {
          _storage.write('remember_me', true);
          _storage.write('saved_email', email);
          _storage.write('saved_password', password);
        } else {
          _storage.remove('remember_me');
          _storage.remove('saved_email');
          _storage.remove('saved_password');
        }

        _storage.write('isLoggedIn', true);
        _storage.write('user_email', email);
        Get.offAllNamed(Routes.dashboard);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "auth_failed".tr;
      if (e.code == 'user-not-found') errorMessage = "user_not_found".tr;
      else if (e.code == 'wrong-password') errorMessage = "wrong_password".tr;
      
      Get.snackbar("error".tr, errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ---  CONNEXION GOOGLE ---
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          _storage.write('isLoggedIn', true);
          _storage.write('user_email', googleUser.email);
          Get.offAllNamed(Routes.dashboard);
        }
      }
    } catch (error) {
      Get.snackbar("error".tr, "google_error".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent);
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