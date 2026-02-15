import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../routes/routes.dart';

class LoginController extends GetxController {
  final _storage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;

  void toggleRememberMe(bool? val) => rememberMe.value = val ?? false;
  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;

  Future<void> login() async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(), password: passwordController.text.trim());
      _storage.write('isLoggedIn', true);
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      Get.snackbar("Erreur", "Identifiants incorrects", backgroundColor: Colors.redAccent);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        // Initialisation identique au signup si c'est un nouvel utilisateur Google
        WriteBatch batch = _firestore.batch();
        batch.set(_firestore.collection('users').doc(uid), {
          'uid': uid, 'fullName': googleUser.displayName, 'email': googleUser.email, 'role': 'user', 'createdAt': FieldValue.serverTimestamp(),
        });
        for (int i = 1; i <= 8; i++) {
          batch.set(_firestore.collection('users').doc(uid).collection('zones').doc('zone$i'), {
            'name': 'Zone $i', 'enabled': false, 'humidity': 0, 'azote': 0, 'sante': 10, 'lat': 34.7335, 'lng': 10.7668,
          });
        }
        batch.set(_firestore.collection('users').doc(uid).collection('commands').doc('variateur'), {
          'frequency': 0, 'isOn': false,
        });
        await batch.commit();
      }

      _storage.write('isLoggedIn', true);
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      Get.snackbar("Erreur Google", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}