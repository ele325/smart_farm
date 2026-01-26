import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('language'.tr)),
      body: ListView(
        children: [
          ListTile(
            title: const Text('العربية'),
            onTap: () {
              Get.updateLocale(const Locale('ar'));
              Get.offAllNamed(
                Routes.dashboard,
              ); // Keeping offAllNamed because duplicates of RootPage are bad?
              // If we do toNamed, we have Language -> Root.
              // If we do offAllNamed, we have Root.
              // User wants BACK BUTTON.
              // If I use toNamed, Back Button works naturally.
              Get.toNamed(Routes.dashboard);
            },
          ),
          ListTile(
            title: const Text('Français'),
            onTap: () {
              Get.updateLocale(const Locale('fr'));
              Get.offAllNamed(
                Routes.dashboard,
              ); // Keeping offAllNamed because duplicates of RootPage are bad?
              // If we do toNamed, we have Language -> Root.
              // If we do offAllNamed, we have Root.
              // User wants BACK BUTTON.
              // If I use toNamed, Back Button works naturally.
              Get.toNamed(Routes.dashboard);
            },
          ),
          ListTile(
            title: const Text('English'),
            onTap: () {
              Get.updateLocale(const Locale('en'));
              Get.offAllNamed(
                Routes.dashboard,
              ); // Keeping offAllNamed because duplicates of RootPage are bad?
              // If we do toNamed, we have Language -> Root.
              // If we do offAllNamed, we have Root.
              // User wants BACK BUTTON.
              // If I use toNamed, Back Button works naturally.
              Get.toNamed(Routes.dashboard);
            },
          ),
        ],
      ),
    );
  }
}
