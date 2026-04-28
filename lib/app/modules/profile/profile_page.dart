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
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => const SettingsPage()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(controller, context),
            const SizedBox(height: 25),

            SectionCard(
              title: "current_subscription".tr,
              child: Obx(
                () => InfoCard(
                  title: "plan".tr,
                  value: controller.currentPlan.value.tr,
                  icon: Icons.verified,
                  statusColor: Colors.blue,
                ),
              ),
            ),

            SectionCard(
              title: "buy_additional_services".tr,
              child: Column(
                children: [
                  _buildServiceTile(
                    "growth_analysis",
                    Icons.analytics_outlined,
                    controller,
                  ),
                  const Divider(),
                  _buildServiceTile(
                    "fertilization_plan",
                    Icons.grass,
                    controller,
                  ),
                ],
              ),
            ),

            SectionCard(
              title: "billing_history".tr,
              child: Obx(
                () => Column(
                  children: controller.billingHistory.map((facture) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.receipt_long,
                        color: Colors.blueGrey,
                      ),
                      title: Text(facture['service']!.tr),
                      subtitle: Text(
                        "${facture['date']} - ${facture['prix']}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.download_rounded,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          controller.downloadInvoice(facture['id']!);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.logout(),
                icon: const Icon(Icons.logout),
                label: Text("logout".tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    ProfileController controller,
    BuildContext context,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Obx(() {
              if (controller.profileImagePath.value.isNotEmpty) {
                return CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(
                    File(controller.profileImagePath.value),
                  ),
                );
              }

              if (controller.googlePhotoUrl.value.isNotEmpty) {
                return CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    controller.googlePhotoUrl.value,
                  ),
                  onBackgroundImageError: (_, __) {},
                );
              }

              return CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green[50],
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.green,
                ),
              );
            }),

            CircleAvatar(
              backgroundColor: const Color(0xFF1B5E20),
              radius: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showImagePicker(context, controller),
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        Obx(
          () => Text(
            controller.userName.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Obx(
          () => Text(
            controller.email.value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTile(
    String titleKey,
    IconData icon,
    ProfileController controller,
  ) {
    return Obx(() {
      final alreadyExists = controller.billingHistory.any(
        (item) => item['service'] == titleKey,
      );

      final disabled = controller.isLoading.value || alreadyExists;

      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          color: disabled ? Colors.grey : Colors.green[700],
        ),
        title: Text(
          titleKey.tr,
          style: TextStyle(
            color: disabled ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: alreadyExists
            ? const Text(
                'Déjà demandé',
                style: TextStyle(color: Colors.orange),
              )
            : null,
        trailing: controller.isLoading.value
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                alreadyExists ? Icons.check_circle : Icons.chevron_right,
                color: alreadyExists ? Colors.green : Colors.grey,
              ),
        onTap: disabled
            ? null
            : () {
                controller.buyService(titleKey);
              },
      );
    });
  }

  void _showImagePicker(
    BuildContext context,
    ProfileController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.green,
                ),
                title: Text('gallery'.tr),
                onTap: () => controller.pickImage(ImageSource.gallery),
              ),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.green,
                ),
                title: Text('camera'.tr),
                onTap: () => controller.pickImage(ImageSource.camera),
              ),

              if (controller.profileImagePath.value.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: Text(
                    'delete_photo'.tr,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () => controller.deletePhoto(),
                ),
              ],

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}