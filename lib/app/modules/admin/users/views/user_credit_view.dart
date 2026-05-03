import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/user_credit_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

/// Vue d'ajustement de solde utilisateur (Admin)
///
/// Formulaire pour créditer ou débiter le compte d'un membre.
///
/// Composants:
/// - AppBar: Titre "Ajuster le solde"
/// - Card informations: Nom utilisateur + solde actuel
/// - TextField montant: accepte + ou - (ex: +50 ou -20)
/// - TextField notes: optionnel, pour justification
/// - Instructions: aide visuelle pour montant positif/négatif
/// - Bouton soumission: "Ajuster le solde"
///
/// Règles d'affichage:
/// - Solde actuel affiché avec 2 décimales
/// - Couleur solde: vert si positif, rouge si négatif
/// - Instructions claires: "+ pour crédit, - pour débit"
///
/// Validation:
/// - Montant != 0 requis
/// - Format numérique valide (double.tryParse)
/// - Notes optionnelles (texte libre)
///
/// Exemples d'utilisation:
/// - Crédit: +50 avec notes "Remboursement erreur caisse"
/// - Débit: -10 avec notes "Pénalité verre cassé"
///
/// Workflow:
/// - Saisie montant et notes → Validation → Ajustement compte → Message succès → Retour liste
class UserCreditView extends GetView<UserCreditController> {
  const UserCreditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = controller.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuster le solde'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            // User info
            if (user != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32.r,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '${user.firstName[0]}${user.lastName[0]}'
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Divider(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Solde actuel: ',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          Text(
                            '${user.balance.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 24.h),

            // Amount field
            TextField(
              controller: controller.amountController,
              decoration: InputDecoration(
                labelText: 'Montant (€)',
                hintText: 'Positif pour créditer, négatif pour débiter',
                prefixIcon: const Icon(Icons.euro),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),

            SizedBox(height: 12.h),

            // Quick amount buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.amountController.text = '10';
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    ),
                    child: const Text('+10€'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.amountController.text = '20';
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    ),
                    child: const Text('+20€'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.amountController.text = '50';
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    ),
                    child: const Text('+50€'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Quick debit buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.amountController.text = '-5';
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('-5€'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.amountController.text = '-10';
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('-10€'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.amountController.text = '-20';
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('-20€'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Notes field
            TextField(
              controller: controller.notesController,
              decoration: InputDecoration(
                labelText: 'Notes / Raison (optionnel)',
                hintText: 'Ajoutez une note explicative...',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              maxLines: 3,
            ),

            SizedBox(height: 32.h),

            // Submit button
            Obx(
              () => SizedBox(
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.creditAccount,
                  icon: controller.isLoading.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add_circle),
                  label: Text(
                    controller.isLoading.value
                        ? 'Traitement...'
                        : 'Valider l\'ajustement',
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

            SizedBox(height: 12.h),

            // Cancel button
            SizedBox(
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => Get.back(),
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
    );
  }
}
