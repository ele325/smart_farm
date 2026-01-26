import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/app_button.dart';
import '../../../routes/routes.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER VERT ---
            Container(
              height: 220,
              width: double.infinity,
              color: AppColors.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.eco, color: AppColors.primary, size: 50),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Irrigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // --- FORMULAIRE ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('email'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      hintText: 'email'.tr,
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('password'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Seul ce Obx est nécessaire car il écoute isPasswordHidden.value
                  Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.isPasswordHidden.value,
                    decoration: InputDecoration(
                      hintText: 'password'.tr,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(controller.isPasswordHidden.value 
                            ? Icons.visibility_off 
                            : Icons.visibility),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (val) {}),
                      Text('remember_me'.tr, style: const TextStyle(fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // BOUTON CONNEXION (Pas de Obx ici pour éviter l'erreur)
                  AppButton(
                    title: 'login'.tr.toUpperCase(),
                    onTap: () => controller.login(),
                  ),

                  // LIEN MOT DE PASSE OUBLIÉ
                  Center(
                    child: TextButton(
                      onPressed: () => Get.toNamed(Routes.forgotPassword),
                      child: Text('forgot_password'.tr, 
                          style: const TextStyle(color: Colors.black54)),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or'.tr, style: const TextStyle(color: Colors.grey)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // BOUTON GOOGLE
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.login, color: Colors.red), 
                    label: Text('google_login'.tr, 
                        style: const TextStyle(color: Colors.black87)),
                    onPressed: () => controller.loginWithGoogle(),
                  ),

                  const SizedBox(height: 30),
                  
                  // LIEN CRÉER UN COMPTE CORRIGÉ (SANS NO_ACCOUNT)
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.toNamed(Routes.signup),
                      child: Text(
                        'create_account'.tr,
                        style: const TextStyle(
                          color: AppColors.primary, 
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // SÉLECTEUR DE LANGUE (Obx retiré pour corriger l'écran rouge)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLangBtn('AR', 'ar'),
                      const SizedBox(width: 10),
                      _buildLangBtn('FR', 'fr'),
                      const SizedBox(width: 10),
                      _buildLangBtn('EN', 'en'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Center(child: Text('v2.1.3', 
                      style: TextStyle(color: Colors.grey, fontSize: 10))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction simplifiée sans Obx pour éviter l'erreur GetX détectée
  Widget _buildLangBtn(String label, String langCode) {
    bool isSelected = Get.locale?.languageCode == langCode;
    return GestureDetector(
      onTap: () {
        Get.updateLocale(Locale(langCode));
        GetStorage().write('language_code', langCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}