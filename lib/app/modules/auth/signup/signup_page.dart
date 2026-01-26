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
            // --- HEADER VERT AVEC LOGO ---
            Container(
              height: 200,
              width: double.infinity,
              color: AppColors.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.eco, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text('create_account'.tr, 
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildInputField(controller.nameController, 'full_name'.tr, Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildInputField(controller.emailController, 'email'.tr, Icons.email_outlined),
                  const SizedBox(height: 15),
                  _buildInputField(controller.cinController, 'CIN', Icons.badge_outlined),
                  const SizedBox(height: 15),
                  
                  // Mot de passe
                  Obx(() => _buildInputField(
                    controller.passwordController, 
                    'password'.tr, 
                    Icons.lock_outline,
                    isPass: true,
                    hidden: controller.isPasswordHidden.value,
                    onToggle: controller.togglePassword,
                  )),
                  const SizedBox(height: 15),

                  // Confirmation
                  Obx(() => _buildInputField(
                    controller.confirmPasswordController, 
                    'confirm_password'.tr, 
                    Icons.lock_reset,
                    isPass: true,
                    hidden: controller.isConfirmHidden.value,
                    onToggle: controller.toggleConfirm,
                  )),

                  const SizedBox(height: 30),

                  AppButton(
                    title: 'register_btn'.tr.toUpperCase(),
                    onTap: () => controller.signup(),
                  ),

                  const SizedBox(height: 20),

                  // Lien Already have an account
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Text(
                        'already_have_account'.tr,
                        style: const TextStyle(
                          decoration: TextDecoration.underline, // Souligné
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
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

  // Helper pour les champs de saisie
  Widget _buildInputField(TextEditingController ctrl, String hint, IconData icon, 
      {bool isPass = false, bool hidden = false, VoidCallback? onToggle}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass ? hidden : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPass ? IconButton(icon: Icon(hidden ? Icons.visibility_off : Icons.visibility), onPressed: onToggle) : null,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}