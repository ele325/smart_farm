import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/routes.dart';

class ProfileController extends GetxController {
  final _storage = GetStorage();
  final _picker = ImagePicker();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  var userName = ''.obs;
  var email = ''.obs;
  var units = 'metric'.obs;
  var profileImagePath = ''.obs;
  var googlePhotoUrl = ''.obs;
  var currentPlan = 'premium'.obs;
  var isLoading = false.obs;

  var billingHistory = <Map<String, String>>[
    {
      'id': 'INV-001',
      'date': '15/01/2026',
      'service': 'annuel_sub',
      'prix': '250 DT',
    },
    {
      'id': 'INV-002',
      'date': '20/01/2026',
      'service': 'growth_analysis',
      'prix': '50 DT',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();

    final firebaseUser = _auth.currentUser;

    userName.value =
        firebaseUser?.displayName ?? _storage.read('user_name') ?? 'Agriculteur';

    email.value =
        firebaseUser?.email ?? _storage.read('user_email') ?? '';

    googlePhotoUrl.value = firebaseUser?.photoURL ?? '';

    final uid = firebaseUser?.uid ?? 'default';

    profileImagePath.value = _storage.read('profile_pic_$uid') ?? '';
    units.value = _storage.read('user_units') ?? 'metric';
    currentPlan.value = _storage.read('user_plan') ?? 'premium';

    _syncToFirestore();
  }

  Future<void> _syncToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'subscription': {
          'plan': currentPlan.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        'billing': billingHistory.map((b) {
          return {
            'id': b['id'],
            'date': b['date'],
            'service': b['service'],
            'prix': b['prix'],
          };
        }).toList(),
        'settings': {
          'units': units.value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }

  Future<void> changePlan(String newPlan) async {
    currentPlan.value = newPlan;
    _storage.write('user_plan', newPlan);

    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'subscription': {
        'plan': newPlan,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> buyService(String serviceKey) async {
    if (isLoading.value) return;

    final alreadyExists = billingHistory.any(
      (item) => item['service'] == serviceKey,
    );

    if (alreadyExists) {
      Get.snackbar(
        'Info',
        'Ce service est déjà demandé',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final now = DateTime.now();

      final dateStr =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      final invId = 'INV-${now.millisecondsSinceEpoch}';

      final prix = serviceKey == 'growth_analysis' ? '50 DT' : '80 DT';

      final newEntry = {
        'id': invId,
        'date': dateStr,
        'service': serviceKey,
        'prix': prix,
      };

      billingHistory.add(newEntry);

      await _firestore.collection('users').doc(user.uid).set({
        'billing': billingHistory.map((b) {
          return {
            'id': b['id'],
            'date': b['date'],
            'service': b['service'],
            'prix': b['prix'],
          };
        }).toList(),
      }, SetOptions(merge: true));

      Get.snackbar(
        'success'.tr,
        '${'request_for'.tr} ${serviceKey.tr} ${'is_pending'.tr}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleUnits() {
    units.value = units.value == 'metric' ? 'imperial' : 'metric';
    _storage.write('user_units', units.value);

    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).set({
      'settings': {
        'units': units.value,
        'updatedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final uid = _auth.currentUser?.uid ?? 'default';

        profileImagePath.value = image.path;
        _storage.write('profile_pic_$uid', image.path);
        googlePhotoUrl.value = '';

        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
      }
    } catch (e) {
      Get.snackbar(
        'erreur'.tr,
        'access_denied'.tr,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deletePhoto() {
    final uid = _auth.currentUser?.uid ?? 'default';

    profileImagePath.value = '';
    _storage.remove('profile_pic_$uid');
    googlePhotoUrl.value = _auth.currentUser?.photoURL ?? '';

    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    Get.snackbar(
      'success'.tr,
      'photo_deleted'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void downloadInvoice(String invoiceId) {
    Get.snackbar(
      'loading'.tr,
      '${'invoice'.tr} $invoiceId ${'downloaded'.tr}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  void logout() {
    _auth.signOut();
    _storage.write('isLoggedIn', false);
    Get.offAllNamed(Routes.login);
  }

  void changeLanguage(String langCode) {
    Get.updateLocale(Locale(langCode));
    _storage.write('language_code', langCode);
  }

  Future<void> makePhoneCall() async {
    await launchUrl(Uri.parse('tel:+21653140011'));
  }

  Future<void> contactEmail() async {
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: 'contact@robocare.tn',
      ),
    );
  }
}