import 'package:get/get.dart';
import '../modules/auth/login/login_page.dart';
import '../modules/auth/signup/signup_page.dart';
import '../modules/auth/language_page.dart';
import '../modules/auth/forgot_password/forgot_password_page.dart';
import '../modules/root/root_page.dart';
import '../modules/zones/zones_page.dart';
import '../modules/thresholds/thresholds_page.dart';
import '../modules/pump/pump_page.dart';
import '../modules/history/history_page.dart';
import '../modules/alerts/alerts_page.dart';
import '../modules/map/map_page.dart';
import '../modules/profile/profile_page.dart';
import 'routes.dart';

class AppPages {
  static final pages = [
    // Auth - Corrigé ici
    GetPage(name: Routes.login, page: () => LoginPage()),
    GetPage(name: Routes.forgotPassword, page: () => ForgotPasswordPage()),
    GetPage(name: Routes.signup, page: () => SignupPage()), 
    GetPage(name: Routes.language, page: () => const LanguagePage()),

    // Main
    GetPage(name: Routes.dashboard, page: () => RootPage()),

    // Features
    GetPage(name: Routes.zones, page: () => ZonesPage()),
    GetPage(name: Routes.thresholds, page: () => ThresholdsPage()),
    GetPage(name: Routes.pump, page: () => PumpPage()),
    GetPage(name: Routes.history, page: () => HistoryPage()),
    GetPage(name: Routes.alerts, page: () => AlertsPage()),
    GetPage(name: Routes.map, page: () => MapPage()),
    GetPage(name: Routes.profile, page: () => ProfilePage()),
  ];
}