import 'package:get/get.dart';
import '../controllers/users_controller.dart';

/// Injection de dépendances pour le module Users Admin (Liste utilisateurs)
///
/// Initialise le UsersController pour la gestion de la liste des membres.
/// Permet affichage, recherche, modification et crédit/débit des comptes.
class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersController>(() => UsersController());
  }
}
