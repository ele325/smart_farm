import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async'; // Nécessaire pour TimeoutException

import 'app/routes/app_pages.dart';
import 'app/routes/routes.dart';
import 'app/translations/app_translations.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  // 1. Indispensable pour lier Flutter aux plugins natifs
  WidgetsFlutterBinding.ensureInitialized();
  
  // LOG NUMÉRO 1 : Si tu ne vois pas ça, l'app ne s'est pas lancée du tout
  debugPrint("######################################");
  debugPrint("🚀 [SYSTEM] : DÉMARRAGE DE L'APPLICATION");
  debugPrint("######################################");

  try {
    // 2. Initialisation des dates
    await initializeDateFormatting('fr_FR', null);
    debugPrint("✅ [INIT] : Dates initialisées (fr_FR)");

    // 3. Initialisation Firebase avec un Timeout
    debugPrint("🔥 [INIT] : Connexion à Firebase...");
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint("❌ [ERROR] : Firebase Timeout ! Vérifie ton Google-Services.json ou ta connexion.");
        throw TimeoutException("Délai d'attente Firebase dépassé.");
      },
    );
    debugPrint("✅ [INIT] : Firebase connecté.");

    // 4. Initialisation du stockage local
    await GetStorage.init();
    debugPrint("📦 [INIT] : GetStorage initialisé.");

  } catch (e) {
    debugPrint("🚨 [CRITICAL ERROR] lors de l'initialisation : $e");
  }

  debugPrint("🏁 [SYSTEM] : Lancement de SmartFarmApp...");
  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    
    // Lecture des préférences sauvegardées
    final bool isLoggedIn = storage.read('isLoggedIn') ?? false;
    String langCode = storage.read('language_code') ?? 'ar';

    debugPrint("ℹ️ [APP] : Utilisateur connecté ? $isLoggedIn");
    debugPrint("ℹ️ [APP] : Langue active : $langCode");

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