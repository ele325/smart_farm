import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final ForgotPasswordController controller = Get.put(
    ForgotPasswordController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ✅ On enlève l'appBar ici pour utiliser un Container personnalisé dans le body
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ BANDEAU VERT (Identique à SignupPage)
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primary,
              child: Stack(
                // Utilisation de Stack pour placer le bouton retour
                children: [
                  // Bouton Retour
                  Positioned(
                    top: 40, // Ajustez selon la barre de statut
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  // Logo et Texte
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/robocare_logo.png',
                            height: 70,
                            width: 70,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.eco,
                                  color: AppColors.primary,
                                  size: 50,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Note: J'utilise 'forgot_password' ici pour le titre
                        Text(
                          'Smart Irrigation'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FORMULAIRE
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Sous-titre informatif
                  Text(
                    'enter_your_mail'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  _buildLabel('email'.tr),
                  _buildInputField(
                    controller.emailController,
                    'email_hint'.tr,
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 40),

                  // BOUTON RÉINITIALISER
                  Obx(
                    () => AppButton(
                      title: "reset_password_btn".tr.toUpperCase(),
                      isLoading: controller.isLoading.value,
                      onTap: () => controller.resetPassword(),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // RETOUR CONNEXION
                  Center(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'back_to_login'.tr,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- WIDGETS DE CONSTRUCTION (Identiques à SignupPage) ----------
  Widget _buildLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildInputField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
