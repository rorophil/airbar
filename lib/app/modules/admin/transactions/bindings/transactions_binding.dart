import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';

/// Injection de dépendances pour le module Transactions Admin
///
/// Initialise le TransactionsController pour l'historique des transactions.
/// Permet affichage, filtrage par utilisateur/type, et remboursements.
class TransactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}
