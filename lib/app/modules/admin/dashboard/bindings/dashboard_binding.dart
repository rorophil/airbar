import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

/// Injection de dépendances pour le module Dashboard Admin
///
/// Initialise le DashboardController pour le tableau de bord administrateur.
/// Point d'entrée principal de l'interface admin avec accès à tous les modules.
///
/// Pattern GetX: Controller créé à la demande (lazy) et libéré automatiquement.
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrement lazy du controller dashboard
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
