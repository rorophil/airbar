import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../controllers/cashier_receipt_controller.dart';
import '../../../core/values/app_colors.dart';

/// Vue du reçu de vente caisse
class CashierReceiptView extends GetView<CashierReceiptController> {
  const CashierReceiptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu de vente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600.w),
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Icône de succès
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 60.sp, color: Colors.white),
                ),
                SizedBox(height: 24.h),

                Text(
                  'Vente réussie !',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 32.h),

                // Détails de la transaction
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'N° Transaction',
                          '#${controller.transaction.id}',
                        ),
                        Divider(height: 24.h),
                        _buildInfoRow(
                          'Date',
                          dateFormat.format(controller.transaction.timestamp),
                        ),
                        Divider(height: 24.h),
                        _buildInfoRow(
                          'Mode de paiement',
                          controller.transaction.paymentMethod ==
                                  PaymentMethod.cash
                              ? 'Espèces'
                              : 'Carte bancaire',
                        ),
                        Divider(height: 24.h),
                        _buildInfoRow(
                          'Montant',
                          '${controller.transaction.totalAmount.toStringAsFixed(2)} €',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => OutlinedButton.icon(
                          onPressed: controller.isGeneratingPdf.value
                              ? null
                              : controller.printReceipt,
                          icon: controller.isGeneratingPdf.value
                              ? SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(kIsWeb ? Icons.download : Icons.save),
                          label: Text(
                            kIsWeb ? 'Télécharger PDF' : 'Sauvegarder PDF',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Bouton nouvelle vente
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.startNewSale,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: const Text('Nouvelle vente'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
