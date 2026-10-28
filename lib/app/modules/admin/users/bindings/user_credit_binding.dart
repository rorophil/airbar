import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/user_credit_controller.dart';

/// Injection de dépendances pour le module UserCredit (Crédit/Débit compte)
///
/// Initialise le UserCreditController pour l'ajustement des soldes.
/// Supporte montants positifs (crédit) et négatifs (débit) avec validation.
class UserCreditBinding extends Bindings {
  UserCreditBinding() {
    Trace.create('UserCreditBinding');
  }

  @override
  void dependencies() {
    Trace.call('UserCreditBinding', 'dependencies');
    Get.lazyPut<UserCreditController>(() => UserCreditController());
  }
}
