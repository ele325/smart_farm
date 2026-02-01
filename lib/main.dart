import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';

// Tes imports personnalisés
import 'app/routes/app_pages.dart';
import 'app/routes/routes.dart';
import 'app/translations/app_translations.dart';
import 'app/core/theme/app_theme.dart';
import 'app/services/notification_service.dart'; 

/// --- LOGIQUE ARRIÈRE-PLAN ---
/// Cette fonction doit obligatoirement être en dehors de toute classe.
/// Elle est appelée quand l'application est totalement fermée ou en arrière-plan.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // On doit ré-initialiser Firebase dans cet isolat séparé
  await Firebase.initializeApp();
  debugPrint("📩 [BACK] : Message reçu en arrière-plan : ${message.notification?.title}");
}

void main() async {
  // 1. Indispensable pour lier Flutter aux plugins natifs
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint("######################################");
  debugPrint("🚀 [SYSTEM] : DÉMARRAGE SMART FARM");
  debugPrint("######################################");

  try {
    // 2. Initialisation des dates (Français par défaut)
    await initializeDateFormatting('fr_FR', null);

    // 3. Initialisation Firebase avec Sécurité (Timeout)
    debugPrint("🔥 [INIT] : Connexion à Firebase...");
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint("❌ [ERROR] : Firebase Timeout !");
        throw TimeoutException("Délai d'attente Firebase dépassé.");
      },
    );
    debugPrint("✅ [INIT] : Firebase connecté.");

    // 4. Initialisation du Service de Notification
    await NotificationService.init();
    
    // Configurer le gestionnaire de messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configurer l'écouteur de messages quand l'application est OUVERTE
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 [FOREGROUND] : Notification reçue en direct");
      NotificationService.showNotification(message);
    });

    // 5. Initialisation du stockage local (GetStorage)
    await GetStorage.init();
    debugPrint("📦 [INIT] : GetStorage initialisé.");

  } catch (e) {
    debugPrint("🚨 [CRITICAL ERROR] lors de l'initialisation : $e");
  }

  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    
    // Lecture des préférences sauvegardées
    final bool isLoggedIn = storage.read('isLoggedIn') ?? false;
    // On récupère la langue, sinon 'fr' par défaut
    String langCode = storage.read('language_code') ?? 'fr';

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
      // Redirection intelligente au démarrage
      initialRoute: isLoggedIn ? Routes.dashboard : Routes.login,
      builder: (context, child) {
        return Directionality(
          // Gestion dynamique de la direction (RTL pour l'Arabe)
          textDirection: langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
    );
  }
}