import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/routes.dart';

class LoginController extends GetxController {
  final _storage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>['email']);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    rememberMe.value = _storage.read('remember_me') ?? false;
    if (rememberMe.value) {
      emailController.text = _storage.read('saved_email') ?? "";
      passwordController.text = _storage.read('saved_password') ?? "";
    }
  }

  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;
  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;

  // --- CONNEXION CLASSIQUE ---
  Future<void> login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("error".tr, "fill_all_fields".tr, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        _saveUserSession(email, password); // Sauvegarde des infos
        Get.offAllNamed(Routes.dashboard);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // --- CONNEXION GOOGLE ---
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
          _storage.write('user_email', googleUser.email); // Sauvegarde l'email Google
          _storage.write('user_name', googleUser.displayName); // Sauvegarde le nom Google
          Get.offAllNamed(Routes.dashboard);
        }
      }
    } catch (error) {
      Get.snackbar("error".tr, "google_error".tr, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _saveUserSession(String email, String password) {
    _storage.write('isLoggedIn', true);
    _storage.write('user_email', email); // L'email qui sera affiché sur le profil
    
    if (rememberMe.value) {
      _storage.write('remember_me', true);
      _storage.write('saved_email', email);
      _storage.write('saved_password', password);
    } else {
      _storage.remove('remember_me');
      _storage.remove('saved_email');
      _storage.remove('saved_password');
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage = "auth_failed".tr;
    if (e.code == 'user-not-found') errorMessage = "user_not_found".tr;
    else if (e.code == 'wrong-password') errorMessage = "wrong_password".tr;
    Get.snackbar("error".tr, errorMessage, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}