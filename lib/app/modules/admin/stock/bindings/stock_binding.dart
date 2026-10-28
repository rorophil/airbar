import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/stock_controller.dart';

/// Injection de dépendances pour le module Stock Admin (Gestion stock)
///
/// Initialise le StockController pour la visualisation du stock et l'historique.
/// Affiche les alertes de stock faible et permet le réapprovisionnement.
class StockBinding extends Bindings {
  StockBinding() {
    Trace.create('StockBinding');
  }

  @override
  void dependencies() {
    Trace.call('StockBinding', 'dependencies');
    Get.lazyPut<StockController>(() => StockController());
  }
}
