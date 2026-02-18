import 'package:get/get.dart';

class RootController extends GetxController {
  // L'index réactif de l'onglet sélectionné
  var currentIndex = 0.obs;

  // Change l'index et met à jour l'interface
  void changePage(int index) {
    currentIndex.value = index;
  }
}