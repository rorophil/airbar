import 'package:get/get.dart';
import '../controllers/transactions_controller.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';

/// Injection de dépendances pour le module Transactions Admin
///
/// Initialise le TransactionsController pour l'historique des transactions.
/// Permet affichage, filtrage par utilisateur/type, et remboursements.
class TransactionsBinding extends Bindings {
  TransactionsBinding() {
    Trace.create('TransactionsBinding');
  }

  @override
  void dependencies() {
    Trace.call('TransactionsBinding', 'dependencies');
    Get.lazyPut<TransactionsController>(() => TransactionsController());
  }
}
