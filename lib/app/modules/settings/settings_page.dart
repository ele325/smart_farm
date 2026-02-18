import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../profile/profile_controller.dart';
import '../../widgets/section_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller    = Get.put(SettingsController());
    final profileCtrl   = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("settings".tr),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // SECTION PRÉFÉRENCES
          SectionCard(
            title: "app_preferences".tr,
            child: Column(
              children: [

                // ✅ GetBuilder pour réagir au changement de langue
                GetBuilder<SettingsController>(
                  builder: (ctrl) => _buildTile(
                    "language".tr,
                    Get.locale?.languageCode.toUpperCase() ?? "FR",
                    Icons.language,
                    () => _showLanguageDialog(ctrl),
                  ),
                ),

                const Divider(),

                // ✅ Obx correct — profileCtrl.units est bien une RxString
                Obx(() => _buildTile(
                      "units_measure".tr,
                      profileCtrl.units.value.tr,
                      Icons.straighten,
                      () => controller.toggleUnits(),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECTION AIDE & SUPPORT
          SectionCard(
            title: "help_support".tr,
            child: Column(
              children: [
                _buildSimpleTile(
                  "user_guide".tr,
                  Icons.menu_book,
                  () => _showGuide(context),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: Text("call_support".tr),
                  subtitle: const Text("+216 53 140 011"),
                  trailing: const Icon(Icons.call, color: Colors.green),
                  onTap: () => controller.makePhoneCall(),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email, color: Colors.green),
                  title: Text("send_email".tr),
                  subtitle: const Text("contact@robocare.tn"),
                  trailing: const Icon(Icons.send, size: 18, color: Colors.green),
                  onTap: () => controller.contactEmail(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(SettingsController controller) {
    Get.defaultDialog(
      title: "language_select".tr,
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B5E20),
      ),
      radius: 15,
      content: Column(
        children: [
          _languageTile("🇫🇷  Français",  () => controller.changeLanguage('fr')),
          const Divider(),
          _languageTile("🇬🇧  English",   () => controller.changeLanguage('en')),
          const Divider(),
          _languageTile("🇹🇳  العربية",   () => controller.changeLanguage('ar')),
        ],
      ),
    );
  }

  Widget _languageTile(String label, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.green),
      onTap: onTap,
    );
  }

  void _showGuide(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              "user_guide_title".tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 20),
            _guideItem(Icons.water_drop, "water_management".tr,   "water_management_desc".tr),
            const Divider(),
            _guideItem(Icons.eco,        "ia_fertilization".tr,   "ia_fertilization_desc".tr),
            const Divider(),
            _guideItem(Icons.map,        "satellite_imagery".tr,  "satellite_imagery_desc".tr),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text("understood".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String title, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSimpleTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _guideItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1B5E20), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc,  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}