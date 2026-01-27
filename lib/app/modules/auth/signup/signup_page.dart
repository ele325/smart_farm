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
                  Text('create_account'.tr, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('full_name'.tr),
                  _buildInputField(controller.nameController, 'full_name_hint'.tr, Icons.person_outline),
                  const SizedBox(height: 15),

                  _buildLabel('email'.tr),
                  _buildInputField(controller.emailController, 'email_hint'.tr, Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 15),

                  _buildLabel('cin_number'.tr),
                  _buildInputField(controller.cinController, 'cin_hint'.tr, Icons.badge_outlined),
                  const SizedBox(height: 15),
                  
                  _buildLabel('password'.tr),
                  Obx(() => _buildInputField(controller.passwordController, 'password_hint'.tr, Icons.lock_outline, isPass: true, hidden: controller.isPasswordHidden.value, onToggle: controller.togglePassword)),
                  const SizedBox(height: 15),

                  _buildLabel('confirm_password'.tr),
                  Obx(() => _buildInputField(controller.confirmPasswordController, 'confirm_hint'.tr, Icons.lock_reset, isPass: true, hidden: controller.isConfirmHidden.value, onToggle: controller.toggleConfirm)),

                  const SizedBox(height: 30),
                  Obx(() => AppButton(title: 'register_btn'.tr.toUpperCase(), isLoading: controller.isLoading.value, onTap: () => controller.signup())),

                  const SizedBox(height: 25),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: RichText(
                        text: TextSpan(
                          text: "${'already_have_account'.tr} ",
                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(text: 'login'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
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

  Widget _buildLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)));

  Widget _buildInputField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false, bool hidden = false, VoidCallback? onToggle, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass ? hidden : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon),
        suffixIcon: isPass ? IconButton(icon: Icon(hidden ? Icons.visibility_off : Icons.visibility), onPressed: onToggle) : null,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}