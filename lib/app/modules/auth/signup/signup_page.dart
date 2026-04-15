import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import 'signup_controller.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primary,
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
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.eco, color: AppColors.primary, size: 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'create_account'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ── Formulaire ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom complet
                  _buildLabel('full_name'.tr),
                  _buildTextField(
                    controller.nameController,
                    'full_name_hint'.tr,
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 15),

                  // Email — avec indicateur de validité temps réel
                  _buildLabel('email'.tr),
                  _buildEmailField(),
                  const SizedBox(height: 15),

                  // CIN
                  _buildLabel('cin_number'.tr),
                  _buildTextField(
                    controller.cinController,
                    'cin_hint'.tr,
                    Icons.badge_outlined,
                  ),
                  const SizedBox(height: 15),

                  // Mot de passe
                  _buildLabel('password'.tr),
                  Obx(() => _buildTextField(
                    controller.passwordController,
                    'password_hint'.tr,
                    Icons.lock_outline,
                    isPass:   true,
                    hidden:   controller.isPasswordHidden.value,
                    onToggle: controller.togglePassword,
                  )),
                  const SizedBox(height: 15),

                  // Confirmation mot de passe
                  _buildLabel('confirm_password'.tr),
                  Obx(() => _buildTextField(
                    controller.confirmPasswordController,
                    'confirm_hint'.tr,
                    Icons.lock_reset,
                    isPass:   true,
                    hidden:   controller.isConfirmHidden.value,
                    onToggle: controller.toggleConfirm,
                  )),

                  const SizedBox(height: 30),

                  // Bouton inscription
                  Obx(() => AppButton(
                    title:     'register_btn'.tr.toUpperCase(),
                    isLoading: controller.isLoading.value,
                    onTap:     () => controller.signup(),
                  )),

                  const SizedBox(height: 25),

                  // Lien connexion
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: "${'already_have_account'.tr} ",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'login'.tr,
                              style: const TextStyle(
                                color:      AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
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

  // ── Champ email avec icône de statut réactive ────────────────────────────
  Widget _buildEmailField() {
    return Obx(() {
      final status = controller.emailCheckStatus.value;

      Widget? suffixIcon;
      Color?  borderColor;
      String? helperText;

      switch (status) {
        case 'checking':
          suffixIcon = const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
          break;
        case 'valid':
          suffixIcon  = const Icon(Icons.check_circle, color: Colors.green);
          borderColor = Colors.green;
          break;
        case 'invalid':
          suffixIcon  = const Icon(Icons.cancel, color: Colors.red);
          borderColor = Colors.red;
          helperText  = 'Email invalide, inexistant ou jetable';
          break;
      }

      return TextField(
        controller:   controller.emailController,
        keyboardType: TextInputType.emailAddress,
        onChanged:    controller.checkEmailOnTheFly,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText:   'email_hint'.tr,
          hintStyle:  const TextStyle(fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.email_outlined),
          suffixIcon: suffixIcon,
          helperText: helperText,
          helperStyle: const TextStyle(color: Colors.red, fontSize: 12),
          filled:     true,
          fillColor:  const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor ?? AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      );
    });
  }

  // ── Champs génériques ─────────────────────────────────────────────────────
  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize:   16,
            color:      Colors.black87,
          ),
        ),
      );

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool         isPass   = false,
    bool         hidden   = false,
    VoidCallback? onToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller:    ctrl,
      obscureText:   isPass ? hidden : false,
      keyboardType:  keyboardType,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText:   hint,
        hintStyle:  const TextStyle(fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon),
        suffixIcon: isPass
            ? IconButton(
                icon:      Icon(hidden ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggle,
              )
            : null,
        filled:    true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide.none,
        ),
      ),
    );
  }
}