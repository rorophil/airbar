import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:intl/intl.dart';
import '../controllers/transactions_controller.dart';
import '../../../../core/values/app_colors.dart';

class TransactionsView extends GetView<TransactionsController> {
  const TransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => controller.updateSearchQuery(''),
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onChanged: controller.updateSearchQuery,
              ),
            ),

            // Type filter
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Tous'),
                        selected: controller.selectedType.value == null,
                        onSelected: (selected) {
                          controller.selectType(null);
                        },
                      ),
                      SizedBox(width: 8.w),
                      ChoiceChip(
                        label: const Text('Achats'),
                        selected:
                            controller.selectedType.value ==
                            TransactionType.purchase,
                        onSelected: (selected) {
                          controller.selectType(TransactionType.purchase);
                        },
                      ),
                      SizedBox(width: 8.w),
                      ChoiceChip(
                        label: const Text('Crédits'),
                        selected:
                            controller.selectedType.value ==
                            TransactionType.credit,
                        onSelected: (selected) {
                          controller.selectType(TransactionType.credit);
                        },
                      ),
                      SizedBox(width: 8.w),
                      ChoiceChip(
                        label: const Text('Remboursements'),
                        selected:
                            controller.selectedType.value ==
                            TransactionType.refund,
                        onSelected: (selected) {
                          controller.selectType(TransactionType.refund);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Transactions list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredTransactions.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune transaction trouvée',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: controller.filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction =
                          controller.filteredTransactions[index];
                      return _TransactionCard(
                        transaction: transaction,
                        onRefund: transaction.type == TransactionType.purchase
                            ? () => controller.refundTransaction(transaction)
                            : null,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends GetView<TransactionsController> {
  final Transaction transaction;
  final VoidCallback? onRefund;

  const _TransactionCard({required this.transaction, this.onRefund});

  @override
  Widget build(BuildContext context) {
    final typeColor = controller.getTypeColor(transaction.type);
    final typeLabel = controller.getTypeLabel(transaction.type);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),

                const Spacer(),

                // Amount
                Text(
                  '${transaction.totalAmount >= 0 ? '+' : ''}${transaction.totalAmount.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: transaction.totalAmount >= 0
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: AppColors.textHint,
                ),
                SizedBox(width: 4.w),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // User name
            Row(
              children: [
                Icon(Icons.person, size: 14.sp, color: AppColors.textHint),
                SizedBox(width: 4.w),
                Text(
                  controller.getUserName(transaction.userId),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Notes
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 14.sp, color: AppColors.textHint),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Refund button
            if (onRefund != null) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRefund,
                  icon: const Icon(Icons.undo),
                  label: const Text('Rembourser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    side: const BorderSide(color: Color(0xFFF44336)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
