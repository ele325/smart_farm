import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': {
      // Auth
      'login': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'language': 'اللغة',

      'remember_me': 'تذكرني',
      'forgot_password': 'هل نسيت كلمة السر ؟',
      'or': 'أو',
      'google_login': 'تسجيل الدخول باستخدام جوجل',
      'create_account': 'إنشاء حساب',

      'full_name': 'الاسم الكامل',
      'confirm_password': 'تأكيد كلمة المرور',
      'register_btn': 'إنشاء حساب',
      'already_have_account': 'لديك حساب بالفعل؟ تسجيل الدخول',
      'password_too_weak': 'كلمة المرور ضعيفة (تحتاج 8 رموز مع أرقام وحروف)',
      'passwords_not_match': 'كلمات المرور غير متطابقة',
      'account_created': 'تم إنشاء الحساب بنجاح',

      'erreur': 'خطأ',
      'success': 'نجاح',
      'veuillez_remplir_champs': 'يرجى ملء جميع الحقول',
      'welcome': 'مرحباً',
      'google_error': 'فشل الاتصال بـ Google',

      // Forgot Password
  'enter_your_mail': 'يرجى إدخال بريدك الإلكتروني لإعادة تعيين كلمة المرور',
  'reset_password_btn': 'إعادة تعيين كلمة المرور',
  'back_to_login': 'العودة إلى تسجيل الدخول',
  'email_sent_success': 'تم إرسال رابط الاسترداد.',
  'veuillez_saisir_email_valide': 'يرجى إدخال بريد إلكتروني صحيح',

      // Navigation
      'dashboard': 'لوحة التحكم',
      'zones': 'مناطق الري',
      'alerts': 'التنبيهات',
      'profile': 'الملف الشخصي',

      // Dashboard
      'soil': 'رطوبة التربة',
      'temperature': 'درجة الحرارة',
      'pump': 'حالة المضخة',
      'battery': 'مستوى البطارية',

      // Profile
      'subscription': 'الاشتراك',

      // General
      'overview': 'نظرة عامة',
      'humidity': 'الرطوبة',
    },

    'fr': {
      // Auth
      'login': 'Connexion',
      'email': 'Email',
      'password': 'Mot de passe',
      'language': 'Langue',

      'remember_me': 'Se souvenir de moi',
      'forgot_password': 'Mot de passe oublié ?',
      'or': 'OU',
      'google_login': 'Connexion avec Google',
      'create_account': 'Créer un compte',

      'erreur': 'Erreur',
      'success': 'Succès',
      'veuillez_remplir_champs': 'Veuillez remplir tous les champs',
      'welcome': 'Bienvenue',
      'google_error': 'Échec de la connexion Google',

      'full_name': 'Nom complet',
      'confirm_password': 'Confirmer le mot de passe',
      'register_btn': "S'inscrire",
      'already_have_account': 'Déjà un compte ? Se connecter',
      'password_too_weak':
          'Mot de passe faible (8 caractères : lettres, chiffres, symboles)',
      'passwords_not_match': 'Les mots de passe ne correspondent pas',
      'account_created': 'Compte créé avec succès',

      'enter_your_mail': 'Veuillez entrer votre email pour réinitialiser le mot de passe',
  'reset_password_btn': 'Réinitialiser le mot de passe',
  'back_to_login': 'Retour à la connexion',
  'email_sent_success': 'Un lien de récupération a été envoyé.',
  'veuillez_saisir_email_valide': 'Veuillez saisir un email valide',

      // Navigation
      'dashboard': 'Tableau de bord',
      'zones': 'Zones',
      'alerts': 'Alertes',
      'profile': 'Profil',

      // Dashboard
      'soil': 'Humidité du sol',
      'temperature': 'Température',
      'pump': 'État de la pompe',
      'battery': 'Batterie',

      // Profile
      'subscription': 'Abonnement',

      // General
      'overview': 'Aperçu',
      'humidity': 'Humidité',
    },

    'en': {
      // Auth
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'language': 'Language',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password?',
      'or': 'OR',
      'google_login': 'Login with Google',
      'create_account': 'Create Account',
      'erreur': 'Error',
      'success': 'Success',
      'veuillez_remplir_champs': 'Please fill all fields',
      'welcome': 'Welcome',
      'google_error': 'Google Login Failed',
      'full_name': 'Full Name',
      'confirm_password': 'Confirm Password',
      'register_btn': 'Register',
      'already_have_account': 'Already have an account? Login',
      'password_too_weak': 'Weak password (8 chars: letters, numbers, symbols)',
      'passwords_not_match': 'Passwords do not match',
      'account_created': 'Account created successfully',

      // Navigation
      'dashboard': 'Dashboard',
      'zones': 'Zones',
      'alerts': 'Alerts',
      'profile': 'Profile',

      // Dashboard
      'soil': 'Soil Humidity',
      'temperature': 'Temperature',
      'pump': 'Pump Status',
      'battery': 'Battery',

      // Profile
      'subscription': 'Subscription',

      // General
      'overview': 'Overview',
      'humidity': 'Humidity',
    },
  };
}
