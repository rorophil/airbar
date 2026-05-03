import 'package:get/get.dart';
import '../controllers/stock_controller.dart';

/// Injection de dépendances pour le module Stock Admin (Gestion stock)
///
/// Initialise le StockController pour la visualisation du stock et l'historique.
/// Affiche les alertes de stock faible et permet le réapprovisionnement.
class StockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockController>(() => StockController());
  }
}
