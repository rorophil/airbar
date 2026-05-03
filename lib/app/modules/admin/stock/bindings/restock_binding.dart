import 'package:get/get.dart';
import '../controllers/restock_controller.dart';

/// Injection de dépendances pour le module Restock (Réapprovisionnement)
///
/// Initialise le RestockController pour ajouter du stock aux produits.
/// Gestion spécifique des produits en vrac (ouverture de nouvelles unités).
class RestockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestockController>(() => RestockController());
  }
}
