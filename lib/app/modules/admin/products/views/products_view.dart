import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/products_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.products),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createProduct,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.search,
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
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),

          // Category filters
          Obx(() {
            if (controller.categories.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 50.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Obx(
                      () => ChoiceChip(
                        label: const Text('Tous'),
                        selected: controller.selectedCategoryId.value == null,
                        onSelected: (_) => controller.selectCategory(null),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: controller.selectedCategoryId.value == null
                              ? AppColors.textWhite
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  ...controller.categories.map(
                    (cat) => Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Obx(
                        () => ChoiceChip(
                          label: Text(cat.name),
                          selected:
                              controller.selectedCategoryId.value == cat.id,
                          onSelected: (_) => controller.selectCategory(cat.id),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: controller.selectedCategoryId.value == cat.id
                                ? AppColors.textWhite
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: 8.h),

          // Products list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredProducts.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun produit trouvé',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.filteredProducts.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final product = controller.filteredProducts[index];
                    return _ProductCard(product: product);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends GetView<ProductsController> {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final stockColor = product.stockQuantity == 0
        ? AppColors.stockOut
        : product.stockQuantity <= product.minStockAlert
        ? AppColors.stockLow
        : AppColors.stockOk;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Product icon
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.local_drink,
                    size: 32.sp,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(width: 16.w),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.getCategoryName(product.categoryId),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Icon(
                            Icons.inventory_2,
                            size: 14.sp,
                            color: stockColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: stockColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: product.isActive
                        ? AppColors.success
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    product.isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),

            if (product.description != null) ...[
              SizedBox(height: 12.h),
              Text(
                product.description!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 12.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.editProduct(product),
                    icon: Icon(Icons.edit, size: 18.sp),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Show Activate/Deactivate button based on status
                if (product.isActive)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.toggleActiveStatus(product),
                      icon: Icon(Icons.visibility_off, size: 18.sp),
                      label: const Text('Désactiver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.toggleActiveStatus(product),
                      icon: Icon(Icons.visibility, size: 18.sp),
                      label: const Text('Réactiver'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            // Second row with stock and delete
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.manageStock(product),
                    icon: Icon(Icons.inventory, size: 18.sp),
                    label: const Text('Gérer le stock'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.textHint),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.deleteProduct(product),
                    icon: Icon(Icons.delete_forever, size: 18.sp),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
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
