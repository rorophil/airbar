import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/export_controller.dart';
import '../../../../core/values/app_colors.dart';

class ExportView extends GetView<ExportController> {
  const ExportView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export de données'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(24.w),
          children: [
            // Low stock products section
            Text(
              'Export des produits',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16.h),

            // Info card for low stock
            Card(
              color: AppColors.warning.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: AppColors.warning,
                      size: 30.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Exportez la liste des produits dont le stock est sous le seuil d\'alerte',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Export low stock button
            Obx(
              () => SizedBox(
                height: 60.h,
                child: ElevatedButton.icon(
                  onPressed: controller.isExporting.value
                      ? null
                      : controller.exportLowStockProducts,
                  icon: controller.isExporting.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.inventory_2_outlined, size: 30),
                  label: Text(
                    controller.isExporting.value
                        ? 'Export en cours...'
                        : 'Exporter produits stock faible',
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: AppColors.textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 48.h),

            // Divider
            Divider(thickness: 2, color: AppColors.textHint),

            SizedBox(height: 32.h),

            // Transactions section
            Text(
              'Export des transactions',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16.h),

            // Info card
            Card(
              color: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 30.sp,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Exportez les transactions dans un fichier CSV pour analyse',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Period section
            Text(
              'Période',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16.h),

            // Start date
            Obx(
              () => ListTile(
                leading: Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Date de début'),
                subtitle: Text(
                  controller.startDate.value != null
                      ? DateFormat(
                          'dd/MM/yyyy',
                        ).format(controller.startDate.value!)
                      : 'Non sélectionnée',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: const BorderSide(color: AppColors.textHint),
                ),
                onTap: () => controller.selectStartDate(context),
              ),
            ),

            SizedBox(height: 12.h),

            // End date
            Obx(
              () => ListTile(
                leading: Icon(Icons.calendar_today, color: AppColors.primary),
                title: const Text('Date de fin'),
                subtitle: Text(
                  controller.endDate.value != null
                      ? DateFormat(
                          'dd/MM/yyyy',
                        ).format(controller.endDate.value!)
                      : 'Non sélectionnée',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: const BorderSide(color: AppColors.textHint),
                ),
                onTap: () => controller.selectEndDate(context),
              ),
            ),

            SizedBox(height: 32.h),

            // Filter section
            Text(
              'Filtre (optionnel)',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16.h),

            // Type filter
            Obx(
              () => Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ChoiceChip(
                    label: const Text('Toutes'),
                    selected: controller.selectedType.value == null,
                    onSelected: (selected) {
                      controller.selectType(null);
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      controller.getTypeLabel(TransactionType.purchase),
                    ),
                    selected:
                        controller.selectedType.value ==
                        TransactionType.purchase,
                    onSelected: (selected) {
                      controller.selectType(TransactionType.purchase);
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      controller.getTypeLabel(TransactionType.credit),
                    ),
                    selected:
                        controller.selectedType.value == TransactionType.credit,
                    onSelected: (selected) {
                      controller.selectType(TransactionType.credit);
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      controller.getTypeLabel(TransactionType.refund),
                    ),
                    selected:
                        controller.selectedType.value == TransactionType.refund,
                    onSelected: (selected) {
                      controller.selectType(TransactionType.refund);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 48.h),

            // Export transactions button
            Obx(
              () => SizedBox(
                height: 60.h,
                child: ElevatedButton.icon(
                  onPressed: controller.isExporting.value
                      ? null
                      : controller.exportTransactions,
                  icon: controller.isExporting.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: AppColors.textWhite,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.file_download, size: 30),
                  label: Text(
                    controller.isExporting.value
                        ? 'Export en cours...'
                        : 'Exporter les transactions',
                    style: TextStyle(fontSize: 18.sp),
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
          ],
        ),
      ),
    );
  }
}
