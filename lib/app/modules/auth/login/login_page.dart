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
            // --- HEADER AVEC LOGO ROBOCARE ---
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
                    child: Image.asset(
                      'assets/images/robocare_logo.png',
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                      // Si l'image n'est pas trouvée, affiche une icône de secours
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.eco, color: AppColors.primary, size: 50),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Irrigation',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 26, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Champ Email
                  _buildLabel('email'.tr),
                  const SizedBox(height: 8),
                  _buildInputField(controller.emailController, 'email_hint'.tr, Icons.email_outlined),
                  
                  const SizedBox(height: 20),

                  // Champ Password
                  _buildLabel('password'.tr),
                  const SizedBox(height: 8),
                  Obx(() => _buildInputField(
                    controller.passwordController, 
                    'password_hint'.tr, 
                    Icons.lock_outline,
                    isPass: true,
                    hidden: controller.isPasswordHidden.value,
                    onToggle: controller.togglePasswordVisibility,
                  )),

                  // Remember Me
                  Row(
                    children: [
                      Obx(() => Checkbox(
                        value: controller.rememberMe.value, 
                        onChanged: (val) => controller.toggleRememberMe(val),
                        activeColor: AppColors.primary,
                      )),
                      Text('remember_me'.tr, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bouton Login Principal
                  Obx(() => AppButton(
                    title: 'login'.tr.toUpperCase(),
                    isLoading: controller.isLoading.value,
                    onTap: () => controller.login(),
                  )),

                  // Mot de passe oublié
                  Center(
                    child: TextButton(
                      onPressed: () => Get.toNamed(Routes.forgotPassword),
                      child: Text('forgot_password'.tr, 
                          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Séparateur "OU"
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('or'.tr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- BOUTON GOOGLE CORRIGÉ ---
                  _buildGoogleButton(),

                  const SizedBox(height: 30),

                  // Lien Inscription
                  _buildBottomLink(),

                  const SizedBox(height: 40),

                  // Sélecteur de Langue
                  _buildLanguageSelector(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SOUTIEN ---

  Widget _buildLabel(String label) => Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87));

  Widget _buildInputField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false, bool hidden = false, VoidCallback? onToggle}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass ? hidden : false,
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

  Widget _buildGoogleButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => controller.loginWithGoogle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/google_logo.png',
            height: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Flexible( // Empêche l'erreur de débordement jaune/noir
            child: Text(
              'google_login'.tr,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.toNamed(Routes.signup),
        child: RichText(
          text: TextSpan(
            text: "${'no_account'.tr} ",
            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: 'create_account'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['AR', 'FR', 'EN'].map((l) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: _buildLangBtn(l, l.toLowerCase()),
      )).toList(),
    );
  }

  Widget _buildLangBtn(String label, String langCode) {
    bool isSelected = Get.locale?.languageCode == langCode;
    return GestureDetector(
      onTap: () {
        Get.updateLocale(Locale(langCode));
        GetStorage().write('language_code', langCode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}