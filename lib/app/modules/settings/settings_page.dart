import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../profile/profile_controller.dart';
import '../../widgets/section_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On utilise le ProfileController car il contient déjà changeLanguage et toggleUnits
    final controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: Text("thresholds".tr)), // "Réglages"
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SECTION : PRÉFÉRENCES
          SectionCard(
            title: "app_preferences".tr,
            child: Column(
              children: [
                _buildTile("language".tr, Get.locale?.languageCode.toUpperCase() ?? "FR", Icons.language, 
                  () => _showLanguageDialog(controller)),
                const Divider(),
                Obx(() => _buildTile("units_measure".tr, controller.units.value.tr, Icons.straighten, 
                  () => controller.toggleUnits())),
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // SECTION : AIDE & SUPPORT
          SectionCard(
            title: "help_support".tr,
            child: Column(
              children: [
                _buildSimpleTile("user_guide".tr, Icons.menu_book, () => _showGuide(context)),
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
                  trailing: const Icon(Icons.send, size: 18),
                  onTap: () => controller.contactEmail(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(ProfileController controller) {
    Get.defaultDialog(
      title: "language_select".tr,
      content: Column(
        children: [
          ListTile(title: const Text("Français"), onTap: () => controller.changeLanguage('fr')),
          ListTile(title: const Text("English"), onTap: () => controller.changeLanguage('en')),
          ListTile(title: const Text("العربية"), onTap: () => controller.changeLanguage('ar')),
        ],
      ),
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
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            Text("user_guide_title".tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            _guideItem(Icons.water_drop, "water_management".tr, "water_management_desc".tr),
            const Divider(),
            _guideItem(Icons.eco, "ia_fertilization".tr, "ia_fertilization_desc".tr),
            const Divider(),
            _guideItem(Icons.map, "satellite_imagery".tr, "satellite_imagery_desc".tr),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
                onPressed: () => Get.back(), 
                child: Text("understood".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String t, String v, IconData i, VoidCallback o) => ListTile(
    contentPadding: EdgeInsets.zero, leading: Icon(i, color: Colors.green), title: Text(t), 
    trailing: Text(v, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), onTap: o);

  Widget _buildSimpleTile(String t, IconData i, VoidCallback o) => ListTile(
    contentPadding: EdgeInsets.zero, leading: Icon(i, color: Colors.green), title: Text(t), 
    trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: o);

  Widget _guideItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}