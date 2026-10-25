import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/checkout_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../services/auth_service.dart';

/// Vue du module Checkout (Paiement)
///
/// Affiche l'écran de validation du paiement avec saisie du code PIN.
/// Interface finale avant débit du compte et validation de la transaction.
///
/// Composants principaux:
/// - Card Solde: Affichage du solde actuel et solde après achat
/// - Card Total: Montant total de la commande
/// - Champ PIN: TextField masqué, clavier numérique du système (4 chiffres)
/// - Bouton Payer: Déclenchement de la transaction
/// - Bouton Annuler: Retour au panier
///
/// Interactions:
/// - Saisie PIN → Filtre chiffres uniquement, validation clavier (Entrée)
/// - Tap icône œil → Bascule visibilité PIN
/// - Tap Payer → Transaction atomique + navigation boutique
/// - Tap Annuler → Retour panier
///
/// Sécurité:
/// - PIN masqué par défaut (obscureText: true)
/// - Validation côté serveur avec hash SHA256
/// - PIN effacé après tentative (succès ou échec)
///
/// Transaction atomique:
/// - Vérification PIN + solde + stock
/// - Débit compte + création transaction + déduction stock + vidage panier
/// - Tout ou rien (rollback en cas d'erreur)
class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(AppStrings.checkout),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Informations sur le solde de l'utilisateur
                Obx(() {
                  final user = authService.currentUser.value;
                  if (user == null) return const SizedBox.shrink();

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Votre solde:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${user.balance.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          if (controller.cartTotal > 0) ...[
                            Divider(height: 18.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Montant à payer:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${controller.cartTotal.toStringAsFixed(2)} €',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Divider(height: 18.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nouveau solde:',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${(user.balance - controller.cartTotal).toStringAsFixed(2)} €',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        (user.balance - controller.cartTotal) >=
                                            0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 16.h),

                // PIN entry section
                Text(
                  AppStrings.enterPin,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16.h),

                // Saisie du PIN via le clavier numérique du système
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                            tooltip: controller.showPin.value
                                ? 'Masquer'
                                : 'Afficher',
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
                          if (controller.pin.value.length == 4 &&
                              !controller.isProcessing.value) {
                            controller.processCheckout();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Action buttons
                Obx(
                  () => SizedBox(
                    height: 44.h,
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isProcessing.value ||
                              controller.pin.value.length != 4
                          ? null
                          : controller.processCheckout,
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
                            : AppStrings.confirm,
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
                  child: OutlinedButton.icon(
                    onPressed: controller.cancel,
                    icon: const Icon(Icons.cancel),
                    label: const Text(AppStrings.cancel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
