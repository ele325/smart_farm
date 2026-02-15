import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_controller.dart';
import '../settings/settings_page.dart';
import '../../widgets/section_card.dart'; 
import '../../widgets/info_card.dart';  

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("profile".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () => Get.to(() => const SettingsPage())
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(controller, context),
            const SizedBox(height: 25),

            // SECTION ABONNEMENT
            SectionCard(
              title: "current_subscription".tr,
              child: Obx(() => InfoCard(
                title: "plan".tr,
                value: controller.currentPlan.value.tr,
                icon: Icons.verified,
                statusColor: Colors.blue,
              )),
            ),

            // SECTION SERVICES (Exemple: Analyse de croissance)
            SectionCard(
              title: "buy_additional_services".tr,
              child: Column(
                children: [
                  _buildServiceTile("growth_analysis".tr, Icons.analytics_outlined, controller),
                  const Divider(),
                  _buildServiceTile("fertilization_plan".tr, Icons.grass, controller),
                ],
              ),
            ),

            // SECTION FACTURATION
            SectionCard(
              title: "billing_history".tr,
              child: Obx(() => Column(
                children: controller.billingHistory.map((facture) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long, color: Colors.blueGrey),
                  title: Text(facture['service']!.tr),
                  subtitle: Text("${facture['date']} - ${facture['prix']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.blue),
                    onPressed: () => controller.downloadInvoice(facture['id']!),
                  ),
                )).toList(),
              )),
            ),

            const SizedBox(height: 30),
            
            // BOUTON DECONNEXION
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.logout(),
                icon: const Icon(Icons.logout),
                label: Text("logout".tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red, 
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller, BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Obx(() => CircleAvatar(
              radius: 60,
              backgroundColor: Colors.green[50],
              backgroundImage: controller.profileImagePath.value.isNotEmpty 
                  ? FileImage(File(controller.profileImagePath.value)) : null,
              child: controller.profileImagePath.value.isEmpty 
                  ? const Icon(Icons.person, size: 60, color: Colors.green) : null,
            )),
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 18,
              child: IconButton(
                onPressed: () => _showPicker(context, controller),
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Obx(() => Text(controller.userName.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        Obx(() => Text(controller.email.value, style: TextStyle(color: Colors.grey[600]))),
      ],
    );
  }

  Widget _buildServiceTile(String title, IconData icon, ProfileController controller) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => controller.buyService(title),
    );
  }

  void _showPicker(context, ProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library), 
              title: Text('gallery'.tr), 
              onTap: () => controller.pickImage(ImageSource.gallery)
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt), 
              title: Text('camera'.tr), 
              onTap: () => controller.pickImage(ImageSource.camera)
            ),
          ],
        ),
      ),
    );
  }
}