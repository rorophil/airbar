import 'package:flutter/material.dart';
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
/// - Champ PIN: Saisie sécurisée du code PIN (4 chiffres)
/// - Bouton Payer: Déclenchement de la transaction
/// - Bouton Annuler: Retour au panier
///
/// Interactions:
/// - Saisie PIN → Validation format (4 chiffres)
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

                // PIN display
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 40.w,
                        height: 40.w,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Center(
                          child: Text(
                            index < controller.pin.value.length
                                ? (controller.showPin.value
                                      ? controller.pin.value[index]
                                      : '●')
                                : '',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Show/Hide PIN toggle
                Obx(
                  () => TextButton.icon(
                    onPressed: controller.togglePinVisibility,
                    icon: Icon(
                      controller.showPin.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18.sp,
                    ),
                    label: Text(
                      controller.showPin.value ? 'Masquer' : 'Afficher',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Numeric keypad
                _NumericKeypad(
                  onNumberPressed: (num) {
                    if (controller.pin.value.length < 4) {
                      controller.updatePin(controller.pin.value + num);
                    }
                  },
                  onBackspacePressed: () {
                    if (controller.pin.value.isNotEmpty) {
                      controller.updatePin(
                        controller.pin.value.substring(
                          0,
                          controller.pin.value.length - 1,
                        ),
                      );
                    }
                  },
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
                          borderRadius: BorderRadius.circular(12.r),
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
                        borderRadius: BorderRadius.circular(12.r),
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

class _NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;

  const _NumericKeypad({
    required this.onNumberPressed,
    required this.onBackspacePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 6.h,
      crossAxisSpacing: 6.w,
      children: [
        // Numbers 1-9
        ...List.generate(9, (index) {
          final number = (index + 1).toString();
          return _KeypadButton(
            text: number,
            onPressed: () => onNumberPressed(number),
          );
        }),

        // Empty space
        const SizedBox.shrink(),

        // Number 0
        _KeypadButton(text: '0', onPressed: () => onNumberPressed('0')),

        // Backspace
        _KeypadButton(
          icon: Icons.backspace_outlined,
          onPressed: onBackspacePressed,
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButton({this.text, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        padding: EdgeInsets.symmetric(vertical: 4.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: const BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
      child: text != null
          ? Text(
              text!,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            )
          : Icon(icon, size: 20.sp),
    );
  }
}
