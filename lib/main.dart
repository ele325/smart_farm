import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/routes.dart';
import 'app/translations/app_translations.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation par étapes avec gestion d'erreurs
  try {
    await initializeDateFormatting('fr_FR', null);
    await Firebase.initializeApp();
    await GetStorage.init();
  } catch (e) {
    debugPrint("Erreur init: $e");
  }

  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final bool isLoggedIn = storage.read('isLoggedIn') ?? false;
    String langCode = storage.read('language_code') ?? 'ar';

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farm',
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: Locale(langCode),
      fallbackLocale: const Locale('fr'),
      getPages: AppPages.pages,
      initialRoute: isLoggedIn ? Routes.dashboard : Routes.login,
      builder: (context, child) {
        return Directionality(
          textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}