import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../data/services/pdf_receipt_service.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/pdf_download.dart';

/// Controller pour l'affichage et le traitement du reçu
class CashierReceiptController extends GetxController {
  final _pdfService = PdfReceiptService();
  final _authService = Get.find<AuthService>();

  // Arguments
  late final Transaction transaction;
  late final List items;

  // État réactif
  final isGeneratingPdf = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Récupérer la transaction et les items
    final args = Get.arguments as Map<String, dynamic>;
    transaction = args['transaction'] as Transaction;
    items = args['items'] ?? [];
  }

  /// Génère et affiche/imprime le PDF
  Future<void> printReceipt() async {
    try {
      isGeneratingPdf.value = true;

      final pdfBytes = await _pdfService.generateReceipt(
        transaction: transaction,
        seller: _authService.currentUser.value!,
        items: items,
      );

      // Télécharger/sauvegarder le PDF (web et desktop)
      await downloadPdf(
        pdfBytes,
        'recu_${transaction.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de générer le reçu: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  /// Retourne à la caisse pour une nouvelle vente
  void startNewSale() {
    Get.offAllNamed(AppRoutes.CASHIER);
  }
}
