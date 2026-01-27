import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import 'forgot_password_controller.dart'; 

class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final controller = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('reset_title'.tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        // La flèche de retour automatique dans l'AppBar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('forgot_password'.tr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 10),
              Text('enter_your_mail'.tr, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              _buildLabel('email'.tr),
              const SizedBox(height: 8),
              _buildInputField(controller.emailController, 'email_hint'.tr, Icons.email_outlined),
              const SizedBox(height: 30),
              
              // Bouton de réinitialisation
              Obx(() => AppButton(
                title: "reset_password_btn".tr.toUpperCase(),
                isLoading: controller.isLoading.value,
                onTap: () => controller.resetPassword(), 
              )),

              const SizedBox(height: 25),

              // --- BOUTON RETOUR AJOUTÉ ICI ---
              Center(
                child: TextButton(
                  onPressed: () => Get.back(), // Retourne à la page précédente (Login)
                  child: Text(
                    'back_to_login'.tr, 
                    style: const TextStyle(
                      color: AppColors.primary, 
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87));

  Widget _buildInputField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}