import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/routes.dart';

class SignupController extends GetxController {
  // Contrôleurs de saisie
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cinController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Instances Firebase & Stockage
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  // Variables d'état réactives
  var isPasswordHidden = true.obs;
  var isConfirmHidden = true.obs;
  var isLoading = false.obs;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirm() => isConfirmHidden.value = !isConfirmHidden.value;

  Future<void> signup() async {
    // 1. Validation locale
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        "Erreur", 
        "Les mots de passe ne correspondent pas",
        backgroundColor: Colors.redAccent, 
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      Get.snackbar("Erreur", "Veuillez remplir tous les champs");
      return;
    }

    try {
      isLoading.value = true;

      // 2. Création du compte dans Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        
        // Utilisation d'un Batch pour garantir que toutes les données sont créées ensemble
        WriteBatch batch = _firestore.batch();

        // 3. Document Profil Utilisateur
        DocumentReference userDoc = _firestore.collection('users').doc(uid);
        batch.set(userDoc, {
          'uid': uid,
          'fullName': nameController.text.trim(),
          'email': emailController.text.trim(),
          'cin': cinController.text.trim(),
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 4. Document de Configuration (Seuils globaux)
        // On ne crée pas de zones ici pour laisser l'utilisateur le faire dynamiquement
        DocumentReference configDoc = userDoc.collection('config').doc('thresholds');
        batch.set(configDoc, {
          'minHumidity': 30.0,
          'maxHumidity': 70.0,
          'defaultDuration': 15,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 5. Document Commande Variateur/Pompe
        DocumentReference commandDoc = userDoc.collection('commands').doc('variateur');
        batch.set(commandDoc, {
          'frequency': 0,
          'isOn': false,
          'mode': 'auto', // 'auto' ou 'manual'
          'lastUpdate': FieldValue.serverTimestamp(),
        });

        // Exécution du Batch
        await batch.commit();

        // 6. Sauvegarde locale et Navigation
        _storage.write('isLoggedIn', true);
        _storage.write('user_name', nameController.text.trim());
        _storage.write('user_email', emailController.text.trim());
        
        Get.offAllNamed(Routes.dashboard);
        
        Get.snackbar(
          "Succès", 
          "Compte créé avec succès !",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Une erreur est survenue";
      if (e.code == 'email-already-in-use') message = "Cet email est déjà utilisé";
      if (e.code == 'weak-password') message = "Le mot de passe est trop faible";
      
      Get.snackbar("Erreur d'inscription", message,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Erreur", "Erreur de connexion au serveur",
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Nettoyage de la mémoire
    nameController.dispose();
    emailController.dispose();
    cinController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}