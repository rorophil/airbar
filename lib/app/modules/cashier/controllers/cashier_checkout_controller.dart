import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../data/repositories/cashier_repository.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';
import 'cashier_controller.dart';

/// Controller pour le checkout de la caisse
class CashierCheckoutController extends GetxController {
  final _cashierRepository = CashierRepository();
  final _authService = Get.find<AuthService>();

  // Arguments passés depuis CashierView
  late final List<CashSaleItem> cart;
  late final double total;

  // État réactif
  final pin = ''.obs;
  final showPin = false.obs;
  final selectedPaymentMethod = Rx<PaymentMethod?>(null);
  final isProcessing = false.obs;

  // Getters
  bool get canProceed =>
      pin.value.length == 4 && selectedPaymentMethod.value != null;

  int get sellerId => _authService.currentUser.value!.id!;

  @override
  void onInit() {
    super.onInit();
    
    // Récupérer les arguments
    final args = Get.arguments as Map<String, dynamic>;
    cart = List<CashSaleItem>.from(args['cart'] ?? []);
    total = (args['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Met à jour le PIN
  void updatePin(String value) {
    pin.value = value;
  }

  /// Toggle visibilité du PIN
  void togglePinVisibility() {
    showPin.value = !showPin.value;
  }

  /// Sélectionne le mode de paiement
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  /// Traite la vente caisse
  Future<void> processSale() async {
    if (!canProceed) {
      Get.snackbar(
        'Informations manquantes',
        'Veuillez saisir votre PIN et sélectionner un mode de paiement',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isProcessing.value = true;

      // Convertir les items du panier en CashSaleItemData
      final items = cart.map((item) {
        return CashSaleItemData(
          productId: item.product.id!,
          quantity: item.quantity,
          productPortionId: item.portion?.id,
        );
      }).toList();

      // Appeler le repository
      final transaction = await _cashierRepository.processCashSale(
        sellerId: sellerId,
        items: items,
        paymentMethod: selectedPaymentMethod.value!,
        pin: pin.value,
      );

      // Vider le panier du controller principal
      final cashierController = Get.find<CashierController>();
      cashierController.cashierCart.clear();

      // Naviguer vers le reçu
      Get.offNamed(
        AppRoutes.CASHIER_RECEIPT,
        arguments: {
          'transaction': transaction,
          'items': cart,
        },
      );
    } catch (e) {
      String errorMessage = 'Une erreur est survenue';
      
      if (e.toString().contains('PIN incorrect')) {
        errorMessage = 'Code PIN incorrect';
      } else if (e.toString().contains('Stock insuffisant')) {
        errorMessage = 'Stock insuffisant pour un ou plusieurs produits';
      } else if (e.toString().contains('non trouvé')) {
        errorMessage = 'Produit introuvable';
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Annule le checkout
  void cancel() {
    Get.back();
  }
}
