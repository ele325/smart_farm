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

  Future<void> signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Erreur", "Les mots de passe ne correspondent pas", 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(), password: passwordController.text);

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        WriteBatch batch = _firestore.batch();

        // 1. Infos de base de l'utilisateur
        batch.set(_firestore.collection('users').doc(uid), {
          'uid': uid,
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'cin': cinController.text.trim(),
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Initialisation des Zones (On met l'humidité à 50 par défaut pour éviter l'alerte à 0)
        for (int i = 1; i <= 8; i++) {
          batch.set(_firestore.collection('users').doc(uid).collection('zones').doc('zone$i'), {
            'name': 'Zone $i', 
            'enabled': false, 
            'humidity': 50.0, 
            'azote': 0, 
            'sante': 100, 
            'lat': 34.7335, 
            'lng': 10.7668,
            'ph': 7.0, 
            'temperature': 25.0,
          });
        }

        // 3. Initialisation des seuils (ESSENTIEL pour ton nouveau Dashboard)
        batch.set(_firestore.collection('users').doc(uid).collection('config').doc('thresholds'), {
          'minHumidity': 30.0,
          'maxHumidity': 70.0,
          'duration': 15,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 4. Commande Pompe
        batch.set(_firestore.collection('users').doc(uid).collection('commands').doc('variateur'), {
          'frequency': 0, 
          'isOn': false, 
          'lastUpdate': FieldValue.serverTimestamp(),
        });

        await batch.commit();

        _storage.write('isLoggedIn', true);
        _storage.write('user_name', nameController.text.trim());
        
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      Get.snackbar("Erreur", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
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