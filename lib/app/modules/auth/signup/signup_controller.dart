import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../../routes/routes.dart';

class SignupController extends GetxController {
  // ── Contrôleurs de saisie ──────────────────────────────────────────────────
  final nameController            = TextEditingController();
  final emailController           = TextEditingController();
  final cinController             = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Instances Firebase & Stockage ─────────────────────────────────────────
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  // ── État réactif ──────────────────────────────────────────────────────────
  var isPasswordHidden  = true.obs;
  var isConfirmHidden   = true.obs;
  var isLoading         = false.obs;

  /// '', 'checking', 'valid', 'invalid'
  var emailCheckStatus  = ''.obs;

  Timer? _debounce;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirm()  => isConfirmHidden.value  = !isConfirmHidden.value;

  // ── 1. Validation format email (regex RFC-5322 simplifié) ─────────────────
  bool _isValidEmailFormat(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  // ── 2. Vérification domaine MX via API Disify (gratuite, sans clé) ────────
  //   Retourne true si : format ok + DNS/MX ok + pas un email jetable
  //   En cas d'erreur réseau on laisse passer (fail-open) pour ne pas bloquer.
  Future<bool> _isEmailDomainValid(String email) async {
    try {
      final uri = Uri.parse('https://www.disify.com/api/email/${email.trim()}');
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final bool formatOk      = data['format']     == true;
        final bool dnsOk         = data['dns']        == true;   // domaine avec MX
        final bool notDisposable = data['disposable'] == false;  // pas jetable
        return formatOk && dnsOk && notDisposable;
      }
      return true; // API injoignable → on laisse passer
    } catch (_) {
      return true; // Timeout / pas de réseau → on laisse passer
    }
  }

  // ── 3. Vérification en temps réel (avec debounce 700 ms) ─────────────────
  void checkEmailOnTheFly(String email) {
    _debounce?.cancel();
    if (email.length < 5) {
      emailCheckStatus.value = '';
      return;
    }
    if (!_isValidEmailFormat(email)) {
      emailCheckStatus.value = 'invalid';
      return;
    }
    emailCheckStatus.value = 'checking';
    _debounce = Timer(const Duration(milliseconds: 700), () async {
      final valid = await _isEmailDomainValid(email);
      emailCheckStatus.value = valid ? 'valid' : 'invalid';
    });
  }

  // ── 4. Inscription principale ─────────────────────────────────────────────
  Future<void> signup() async {
    final email    = emailController.text.trim();
    final name     = nameController.text.trim();
    final password = passwordController.text;
    final confirm  = confirmPasswordController.text;

    // Validation champs vides
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    // Validation format email
    if (!_isValidEmailFormat(email)) {
      _showError("Format d'email invalide");
      return;
    }

    // Mot de passe trop court
    if (password.length < 8) {
      _showError('Le mot de passe doit contenir au moins 8 caractères');
      return;
    }

    // Mots de passe identiques
    if (password != confirm) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }

    try {
      isLoading.value = true;

      // ── Vérification domaine MX (bloque emails jetables / domaines inexistants) ──
      final emailValid = await _isEmailDomainValid(email);
      if (!emailValid) {
        _showError(
          "Cet email n'existe pas ou est temporaire.\nUtilisez un email valide.",
        );
        return;
      }

      // ── Création du compte Firebase Auth ──────────────────────────────────
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        final User   user = cred.user!;
        final String uid  = user.uid;

        // ── Envoi du lien de vérification email ───────────────────────────
        await user.sendEmailVerification();

        // ── Écriture Firestore via Batch ──────────────────────────────────
        final WriteBatch batch = _firestore.batch();

        final DocumentReference userDoc =
            _firestore.collection('users').doc(uid);

        batch.set(userDoc, {
          'uid':           uid,
          'fullName':      name,
          'email':         email,
          'cin':           cinController.text.trim(),
          'role':          'user',
          'emailVerified': false, // mis à jour dans emailVerificationPage
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

        // ── Stockage local (pas encore connecté tant que email non vérifié) ──
        _storage.write('isLoggedIn',  false);
        _storage.write('user_name',   name);
        _storage.write('user_email',  email);

        // ── Déconnexion temporaire jusqu'à vérification ───────────────────
        await _auth.signOut();

        // ── Redirection vers page d'attente ───────────────────────────────
        Get.offAllNamed(Routes.emailVerification);

        Get.snackbar(
          'Email envoyé',
          'Vérifiez votre boîte mail pour activer votre compte.',
          backgroundColor: Colors.green,
          colorText:       Colors.white,
          duration:        const Duration(seconds: 5),
          snackPosition:   SnackPosition.BOTTOM,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Une erreur est survenue";
      switch (e.code) {
        case 'email-already-in-use':
          message = "Cet email est déjà associé à un compte";
          break;
        case 'weak-password':
          message = "Le mot de passe est trop faible";
          break;
        case 'invalid-email':
          message = "Format d'email invalide";
          break;
        case 'network-request-failed':
          message = "Erreur réseau, vérifiez votre connexion";
          break;
      }
      _showError(message);
    } catch (_) {
      _showError("Erreur de connexion au serveur");
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
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
    _debounce?.cancel();
    nameController.dispose();
    emailController.dispose();
    cinController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}