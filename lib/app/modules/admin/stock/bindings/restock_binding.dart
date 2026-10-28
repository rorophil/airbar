import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/restock_controller.dart';

/// Injection de dépendances pour le module Restock (Réapprovisionnement)
///
/// Initialise le RestockController pour ajouter du stock aux produits.
/// Gestion spécifique des produits en vrac (ouverture de nouvelles unités).
class RestockBinding extends Bindings {
  RestockBinding() {
    Trace.create('RestockBinding');
  }

  @override
  void dependencies() {
    Trace.call('RestockBinding', 'dependencies');
    Get.lazyPut<RestockController>(() => RestockController());
  }
}
