import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/user_cart_controller.dart';
import '../../../../core/values/app_colors.dart';

/// Vue admin du panier d'un membre
///
/// Permet à un administrateur de consulter le contenu du panier d'un membre
/// et de:
/// - Vider entièrement ce panier (sans débit)
/// - Forcer l'exécution du panier (débit du compte, PIN admin requis)
class UserCartView extends GetView<UserCartController> {
  const UserCartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = controller.targetUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(
          user != null
              ? 'Panier de ${user.firstName} ${user.lastName}'
              : 'Panier',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64.w,
                    color: AppColors.textHint,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Panier vide',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.cartItems.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final item = controller.cartItems[index];
                    return Card(
                      elevation: 1,
                      child: ListTile(
                        title: Text(item.displayName),
                        subtitle: Text(
                          '${item.quantity} × ${item.effectivePrice.toStringAsFixed(2)} €',
                        ),
                        trailing: Text(
                          '${item.subtotal.toStringAsFixed(2)} €',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomBar(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Obx(
                  () => Text(
                    '${controller.total.value.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: controller.isProcessing.value
                          ? null
                          : controller.clearCart,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Vider le panier',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.isProcessing.value
                          ? null
                          : controller.forceCheckout,
                      icon: const Icon(Icons.bolt),
                      label: const Text('Forcer l\'exécution'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
