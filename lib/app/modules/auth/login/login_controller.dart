import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/routes.dart';

class LoginController extends GetxController {
  final _storage     = GetStorage();
  final _auth        = FirebaseAuth.instance;
  final _firestore   = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;
  var isLoading        = false.obs;
  var rememberMe       = false.obs;

  void toggleRememberMe(bool? val)     => rememberMe.value = val ?? false;
  void togglePasswordVisibility()      => isPasswordHidden.value = !isPasswordHidden.value;

  // ── Connexion Email / Mot de passe ────────────────────────────────────────
  Future<void> login() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    try {
      isLoading.value = true;

      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email:    email,
        password: password,
      );

      // ── Guard : email non vérifié ─────────────────────────────────────────
      if (cred.user != null && !cred.user!.emailVerified) {
        await _auth.signOut();
        Get.snackbar(
          'Email non vérifié',
          'Veuillez cliquer sur le lien envoyé dans votre boîte mail.',
          backgroundColor: Colors.orange,
          colorText:       Colors.white,
          duration:        const Duration(seconds: 6),
          snackPosition:   SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () async {
              // Ré-authentification silencieuse pour renvoyer l'email
              try {
                final tmp = await _auth.signInWithEmailAndPassword(
                  email: email, password: password,
                );
                await tmp.user?.sendEmailVerification();
                await _auth.signOut();
                Get.snackbar('Renvoyé', 'Email de vérification renvoyé.',
                    backgroundColor: Colors.green, colorText: Colors.white);
              } catch (_) {}
            },
            child: const Text('Renvoyer', style: TextStyle(color: Colors.white)),
          ),
        );
        return;
      }

      // ── Connexion réussie ─────────────────────────────────────────────────
      if (rememberMe.value) {
        _storage.write('isLoggedIn',  true);
        _storage.write('user_email',  email);
      }
      Get.offAllNamed(Routes.dashboard);

    } on FirebaseAuthException catch (e) {
      String msg = "Identifiants incorrects";
      switch (e.code) {
        case 'user-not-found':        msg = "Aucun compte avec cet email";             break;
        case 'wrong-password':        msg = "Mot de passe incorrect";                  break;
        case 'invalid-credential':    msg = "Identifiants incorrects";                 break;
        case 'user-disabled':         msg = "Ce compte a été désactivé";               break;
        case 'too-many-requests':     msg = "Trop de tentatives. Réessayez plus tard"; break;
        case 'network-request-failed':msg = "Erreur réseau, vérifiez votre connexion"; break;
      }
      _showError(msg);
    } finally {
      isLoading.value = false;
    }
  }

  // ── Connexion Google ──────────────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // annulé par l'utilisateur

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );

      final UserCredential cred =
          await _auth.signInWithCredential(credential);

      final String uid = cred.user!.uid;

      // ── Création du profil Firestore si premier login Google ──────────────
      final DocumentSnapshot userSnap =
          await _firestore.collection('users').doc(uid).get();

      if (!userSnap.exists) {
        final WriteBatch batch = _firestore.batch();

        final DocumentReference userDoc =
            _firestore.collection('users').doc(uid);

        // Les comptes Google sont considérés vérifiés par défaut
        batch.set(userDoc, {
          'uid':           uid,
          'fullName':      googleUser.displayName ?? '',
          'email':         googleUser.email,
          'role':          'user',
          'emailVerified': true,
          'provider':      'google',
          'createdAt':     FieldValue.serverTimestamp(),
        });

        batch.set(userDoc.collection('config').doc('thresholds'), {
          'minHumidity':     30.0,
          'maxHumidity':     70.0,
          'defaultDuration': 15,
          'updatedAt':       FieldValue.serverTimestamp(),
        });

        batch.set(userDoc.collection('commands').doc('variateur'), {
          'frequency':  0,
          'isOn':       false,
          'mode':       'auto',
          'lastUpdate': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      }

      _storage.write('isLoggedIn', true);
      _storage.write('user_email', googleUser.email);
      _storage.write('user_name',  googleUser.displayName ?? '');

      Get.offAllNamed(Routes.dashboard);

    } on FirebaseAuthException catch (e) {
      _showError('Erreur Google : ${e.message ?? e.code}');
    } catch (e) {
      _showError('Erreur Google : ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────
  void _showError(String message) {
    Get.snackbar(
      'Erreur',
      message,
      backgroundColor: Colors.redAccent,
      colorText:       Colors.white,
      snackPosition:   SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}