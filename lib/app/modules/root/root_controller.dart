import 'package:get/get.dart';

class RootController extends GetxController {
  // L'index actuel de la barre de navigation
  var currentIndex = 0.obs;

  // Fonction pour changer d'onglet
  void changePage(int index) {
    currentIndex.value = index;
  }
}