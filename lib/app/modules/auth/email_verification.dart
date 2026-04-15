import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/routes.dart';

/// Page affichée après l'inscription.
/// Poll Firebase toutes les 3 s pour détecter que l'utilisateur
/// a cliqué sur le lien de vérification, puis redirige vers le dashboard.
class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _pollTimer;
  bool   _isSending = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  // ── Polling toutes les 3 secondes ─────────────────────────────────────────
  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        await user?.reload(); // rafraîchit le token depuis Firebase
        if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
          _pollTimer?.cancel();
          // Marquer comme connecté localement
          GetStorage().write('isLoggedIn', true);
          Get.offAllNamed(Routes.dashboard);
        }
      } catch (_) {
        // Ignore les erreurs réseau ponctuelles
      }
    });
  }

  // ── Renvoyer l'email de vérification ─────────────────────────────────────
  Future<void> _resendVerificationEmail() async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        Get.snackbar(
          'Email renvoyé',
          'Vérifiez votre boîte de réception.',
          backgroundColor: Colors.green,
          colorText:       Colors.white,
          snackPosition:   SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      if (mounted) {
        Get.snackbar(
          'Erreur',
          'Impossible de renvoyer l\'email. Réessayez plus tard.',
          backgroundColor: Colors.redAccent,
          colorText:       Colors.white,
          snackPosition:   SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ── Retour à la page de connexion ─────────────────────────────────────────
  Future<void> _backToLogin() async {
    _pollTimer?.cancel();
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed(Routes.login);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Colors.white,
        elevation:        0,
        leading: IconButton(
          icon:      const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _backToLogin,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:        AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size:  56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 28),

              // Titre
              const Text(
                'Vérifiez votre email',
                style: TextStyle(
                  fontSize:   24,
                  fontWeight: FontWeight.bold,
                  color:      Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Sous-titre
              Text(
                'Un lien de confirmation a été envoyé à :',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color:      AppColors.primary,
                  fontSize:   15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Indicateur de polling
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              const Text(
                'En attente de confirmation…',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Bouton renvoyer
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSending ? null : _resendVerificationEmail,
                  icon: _isSending
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isSending ? 'Envoi…' : 'Renvoyer l\'email'),
                  style: OutlinedButton.styleFrom(
                    padding:       const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.primary,
                    side:          const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Utiliser un autre email
              TextButton(
                onPressed: _backToLogin,
                child: const Text(
                  'Utiliser un autre email',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}