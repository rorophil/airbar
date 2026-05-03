import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// Injection de dépendances pour le module Splash
///
/// Initialise et enregistre le SplashController nécessaire pour gérer
/// l'écran de démarrage et la redirection vers la bonne route.
///
/// Pattern GetX: Utilise put() au lieu de lazyPut() car le controller
/// doit être initialisé immédiatement au démarrage de l'app.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrement immédiat du controller splash (pas lazy)
    Get.put<SplashController>(SplashController());
  }
}
