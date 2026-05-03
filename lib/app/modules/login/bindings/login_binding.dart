import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// Injection de dépendances pour le module Login
///
/// Initialise et enregistre le LoginController nécessaire au fonctionnement
/// de l'écran de connexion.
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et automatiquement
/// libéré quand la route login est quittée.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrement lazy du controller de login
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
