import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/cashier_checkout_controller.dart';
import '../../../core/values/app_colors.dart';

/// Vue du checkout de la caisse
class CashierCheckoutView extends GetView<CashierCheckoutController> {
  const CashierCheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Validation de la vente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Récapitulatif du panier
            _buildCartSummary(),
            SizedBox(height: 24.h),

            // Sélection du mode de paiement
            _buildPaymentMethodSelector(),
            SizedBox(height: 24.h),

            // Champ PIN vendeur
            _buildPinField(),
            SizedBox(height: 32.h),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            ...controller.cart.map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.displayName}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Text(
                      '${item.subtotal.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${controller.total.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode de paiement',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildPaymentCard(
                  PaymentMethod.cash,
                  'Espèces',
                  Icons.money,
                  controller.selectedPaymentMethod.value == PaymentMethod.cash,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(
                () => _buildPaymentCard(
                  PaymentMethod.card,
                  'Carte bancaire',
                  Icons.credit_card,
                  controller.selectedPaymentMethod.value == PaymentMethod.card,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    PaymentMethod method,
    String label,
    IconData icon,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => controller.selectPaymentMethod(method),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Entrez votre code PIN',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Obx(
          () => Center(
            child: SizedBox(
              width: 220.w,
              child: TextField(
                controller: controller.pinController,
                autofocus: true,
                obscureText: !controller.showPin.value,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                maxLength: 4,
                enableSuggestions: false,
                autocorrect: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  prefixIcon: const Icon(Icons.pin),
                  suffixIcon: IconButton(
                    tooltip: controller.showPin.value ? 'Masquer' : 'Afficher',
                    icon: Icon(
                      controller.showPin.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: controller.togglePinVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onChanged: controller.updatePin,
                onSubmitted: (_) {
                  if (controller.canProceed && !controller.isProcessing.value) {
                    controller.processSale();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => SizedBox(
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: controller.isProcessing.value || !controller.canProceed
                  ? null
                  : controller.processSale,
              icon: controller.isProcessing.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: AppColors.textWhite,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                controller.isProcessing.value
                    ? 'Traitement...'
                    : 'Confirmer la vente',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 44.h,
          child: Obx(
            () => OutlinedButton.icon(
              onPressed: controller.isProcessing.value
                  ? null
                  : controller.cancel,
              icon: const Icon(Icons.cancel),
              label: const Text('Annuler'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
