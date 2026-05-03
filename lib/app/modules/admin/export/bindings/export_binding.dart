import 'package:get/get.dart';
import '../controllers/export_controller.dart';

/// Injection de dépendances pour le module Export Admin
///
/// Initialise le ExportController pour la génération de rapports.
/// Permet l'export CSV/Excel des utilisateurs, produits et transactions.
class ExportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExportController>(() => ExportController());
  }
}
