import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/cashier_controller.dart';
import '../controllers/cashier_checkout_controller.dart';
import '../controllers/cashier_receipt_controller.dart';
import '../../../data/repositories/cashier_repository.dart';
import '../../../data/repositories/product_portion_repository.dart';

/// Binding pour le module Caisse
class CashierBinding extends Bindings {
  CashierBinding() {
    Trace.create('CashierBinding');
  }

  @override
  void dependencies() {
    Trace.call('CashierBinding', 'dependencies');
    // Repositories
    Get.lazyPut<CashierRepository>(() => CashierRepository());
    // Repository pour gérer les portions des produits en vrac (25cl, 50cl, etc.)
    Get.lazyPut<ProductPortionRepository>(() => ProductPortionRepository());

    // Controllers
    Get.lazyPut<CashierController>(() => CashierController());
    Get.lazyPut<CashierCheckoutController>(() => CashierCheckoutController());
    Get.lazyPut<CashierReceiptController>(() => CashierReceiptController());
  }
}
