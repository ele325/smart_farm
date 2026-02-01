import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../settings/settings_page.dart';
import '../../widgets/section_card.dart'; // Import de ton widget
import '../../widgets/info_card.dart';    // Import de ton widget

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("profile".tr),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Get.to(() => const SettingsPage()))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER PHOTO
            _buildProfileHeader(controller, context),
            
            const SizedBox(height: 25),

            // SECTION ABONNEMENT
            SectionCard(
              title: "Abonnement actuel".tr,
              child: InfoCard(
                title: "Plan".tr,
                value: controller.currentPlan.value,
                icon: Icons.verified,
                statusColor: Colors.blue,
              ),
            ),

            // SECTION SERVICES
            SectionCard(
              title: "Achat de services additionnels".tr,
              child: Column(
                children: [
                  _buildServiceTile("Analyse de croissance".tr, Icons.analytics_outlined, controller),
                  const Divider(),
                  _buildServiceTile("Plan de fertilisation".tr, Icons.grass, controller),
                ],
              ),
            ),

            // SECTION FACTURATION
            SectionCard(
              title: "Facturation et historique".tr,
              child: Obx(() => Column(
                children: controller.billingHistory.map((facture) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long),
                  title: Text(facture['service']!),
                  subtitle: Text("${facture['date']} - ${facture['prix']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.blue),
                    onPressed: () => controller.downloadInvoice(facture['id']!),
                  ),
                )).toList(),
              )),
            ),

            const SizedBox(height: 20),
            
            // BOUTON LOGOUT
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.logout(),
                icon: const Icon(Icons.logout),
                label: Text("Se déconnecter".tr),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
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
              backgroundColor: Colors.green[100],
              backgroundImage: controller.profileImagePath.value.isNotEmpty 
                  ? FileImage(File(controller.profileImagePath.value)) : null,
              child: controller.profileImagePath.value.isEmpty 
                  ? const Icon(Icons.person, size: 60, color: Colors.green) : null,
            )),
            IconButton(
              onPressed: () => _showPicker(context, controller),
              icon: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18)
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() => Text(controller.userName.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Obx(() => Text(controller.email.value, style: const TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget _buildServiceTile(String title, IconData icon, ProfileController controller) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.add_shopping_cart, size: 18),
      onTap: () => controller.buyService(title),
    );
  }

  void _showPicker(context, controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: Text('Galerie'.tr), onTap: () => controller.pickImage(ImageSource.gallery)),
            ListTile(leading: const Icon(Icons.camera_alt), title: Text('Appareil Photo'.tr), onTap: () => controller.pickImage(ImageSource.camera)),
          ],
        ),
      ),
    );
  }
}