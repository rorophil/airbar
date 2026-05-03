import 'package:get/get.dart';
import '../controllers/user_credit_controller.dart';

/// Injection de dépendances pour le module UserCredit (Crédit/Débit compte)
///
/// Initialise le UserCreditController pour l'ajustement des soldes.
/// Supporte montants positifs (crédit) et négatifs (débit) avec validation.
class UserCreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserCreditController>(() => UserCreditController());
  }
}
