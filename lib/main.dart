import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/routes.dart';
import 'app/translations/app_translations.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  // 1. Initialisation des services Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialisation de Firebase
  await Firebase.initializeApp();
  
  // 3. Initialisation du stockage local (GetStorage)
  await GetStorage.init();
  
  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();

    // --- LOGIQUE DE CONNEXION ---
    final bool isLoggedIn = storage.read('isLoggedIn') ?? false;

    // --- LOGIQUE DE LANGUE (FORCÉE ARABE PAR DÉFAUT) ---
    String? langCode = storage.read('language_code');
    
    // Si c'est le premier lancement ou que la langue est vide, on force 'ar'
    if (langCode == null) {
      langCode = 'ar';
      storage.write('language_code', 'ar');
    }

    // Création de la locale basée sur le code (ar, fr, ou en)
    Locale initialLocale = Locale(langCode);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farm',
      theme: AppTheme.lightTheme,
      
      // Configuration des traductions via ton fichier AppTranslations
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr'), // Secours en français si une clé manque
      
      // Gestion des routes
      getPages: AppPages.pages,
      initialRoute: isLoggedIn ? Routes.dashboard : Routes.login,
      
      // Gestion de la direction du texte (RTL pour Arabe, LTR pour les autres)
      builder: (context, child) {
        return Directionality(
          textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}