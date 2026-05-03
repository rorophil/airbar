import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/shop_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

/// Vue du module Shop (Boutique utilisateur)
///
/// Affiche le catalogue de produits disponibles avec filtrage par catégorie et recherche.
/// Interface principale pour les achats des membres de l'aéro-club.
///
/// Composants principaux:
/// - AppBar: Titre + Badge panier + Bouton admin (si admin)
/// - Barre de recherche: Filtrage par texte (nom/description)
/// - Filtres catégories: Chips horizontaux scrollables
/// - Grille de produits: Cards avec image, nom, prix, stock, +panier
/// - Bouton panier flottant: Accès rapide au panier
///
/// Interactions:
/// - Tap catégorie → Filtre les produits
/// - Texte recherche → Filtre en temps réel
/// - Tap produit → Dialog pour sélectionner quantité/portion + ajouter
/// - Tap panier → Navigation vers CartView
/// - Tap admin → Navigation vers DashboardView (admins uniquement)
///
/// Gestion des produits en vrac:
/// - Si isBulkProduct = true, affiche les portions disponibles (25cl, 50cl, etc.)
/// - Prix et stock affichés selon la portion sélectionnée
class ShopView extends GetView<ShopController> {
  const ShopView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.shop),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        actions: [
          // Icône panier avec badge indiquant le nombre d'articles
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: controller.goToCart,
                ),
                if (controller.cartItemCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.w,
                      ),
                      child: Text(
                        '${controller.cartItemCount.value}',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Admin dashboard button (only for admins)
          if (controller.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: controller.goToAdminDashboard,
              tooltip: 'Dashboard Admin',
            ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: AppStrings.logout,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: Column(
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
                              onPressed: () {
                                controller.updateSearchQuery('');
                              },
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
              if (controller.categories.isNotEmpty)
                SizedBox(
                  height: 50.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      // All categories chip
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Obx(
                          () => ChoiceChip(
                            label: const Text('Tous'),
                            selected:
                                controller.selectedCategoryId.value == null,
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
                      // Category chips
                      ...controller.categories.map(
                        (cat) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Obx(
                            () => ChoiceChip(
                              label: Text(cat.name),
                              selected:
                                  controller.selectedCategoryId.value == cat.id,
                              onSelected: (_) =>
                                  controller.selectCategory(cat.id),
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color:
                                    controller.selectedCategoryId.value ==
                                        cat.id
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 8.h),

              // Products grid
              Expanded(
                child: Obx(() {
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

                  return ListView.builder(
                    padding: EdgeInsets.all(12.w),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredProducts[index];
                      if (product.isBulkProduct) {
                        return _BulkProductCard(product: product);
                      }
                      return _ProductCard(product: product);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _ProductCard extends GetView<ShopController> {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: () => _showProductDetails(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Product image placeholder
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  controller.getIconForCategory(
                    controller.getCategoryForProduct(product),
                  ),
                  size: 36.sp,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(width: 12.w),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // Description if available
                    if (product.description != null &&
                        product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    SizedBox(height: 6.h),

                    // Price and stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 14.sp,
                              color: _getStockColor(),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${product.stockQuantity}',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: _getStockColor(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Add to cart icon
              Icon(
                Icons.add_shopping_cart,
                size: 24.sp,
                color: product.stockQuantity > 0
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (product.stockQuantity == 0) return AppColors.stockOut;
    if (product.stockQuantity <= product.minStockAlert)
      return AppColors.stockLow;
    return AppColors.stockOk;
  }

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => _ProductDetailsSheet(product: product),
    );
  }
}

class _BulkProductCard extends GetView<ShopController> {
  final Product product;

  const _BulkProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final portions = controller.getPortionsForProduct(product.id!);
    final activePortions = portions.where((p) => p.isActive).toList();

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and product name
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    controller.getIconForCategory(
                      controller.getCategoryForProduct(product),
                    ),
                    size: 28.sp,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Produit en vrac',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Stock indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 18.sp,
                      color: _getStockColor(),
                    ),
                    Text(
                      '${product.stockQuantity}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _getStockColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Bulk info
            if (product.bulkUnit != null && product.bulkTotalQuantity != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 4.h),
                child: Text(
                  'Contenance: ${product.bulkTotalQuantity} ${product.bulkUnit}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            Divider(height: 16.h),

            // Portions list
            if (activePortions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'Aucune portion disponible',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.error,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...activePortions.map(
                (portion) => InkWell(
                  onTap: product.stockQuantity > 0
                      ? () => _showPortionDialog(context, portion)
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 8.h,
                      horizontal: 8.w,
                    ),
                    margin: EdgeInsets.only(bottom: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                portion.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${portion.quantity} ${product.bulkUnit ?? ""}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${portion.price.toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.add_shopping_cart,
                              size: 20.sp,
                              color: product.stockQuantity > 0
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (product.stockQuantity == 0) return AppColors.stockOut;
    if (product.stockQuantity <= product.minStockAlert)
      return AppColors.stockLow;
    return AppColors.stockOk;
  }

  void _showPortionDialog(BuildContext context, ProductPortion portion) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(portion.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Prix: ${portion.price.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Quantité: ${portion.quantity} ${product.bulkUnit ?? ""}',
              style: TextStyle(fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 1;
              if (quantity > 0) {
                controller.addToCart(
                  product,
                  quantity,
                  productPortionId: portion.id,
                );
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Ajouter au panier'),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailsSheet extends GetView<ShopController> {
  final Product product;

  const _ProductDetailsSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final quantityController = TextEditingController(text: '1');
    final selectedPortion = Rxn<ProductPortion>();

    // For bulk products, load portions
    if (product.isBulkProduct) {
      return _buildBulkProductSheet(
        context,
        selectedPortion,
        quantityController,
      );
    }

    return _buildRegularProductSheet(context, quantityController);
  }

  Widget _buildRegularProductSheet(
    BuildContext context,
    TextEditingController quantityController,
  ) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 8.h),

          // Description
          if (product.description != null)
            Text(
              product.description!,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),

          SizedBox(height: 16.h),

          // Price
          Row(
            children: [
              Text('Prix: ', style: TextStyle(fontSize: 16.sp)),
              Text(
                '${product.price.toStringAsFixed(2)} €',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Stock
          Text(
            'Stock disponible: ${product.stockQuantity}',
            style: TextStyle(
              fontSize: 14.sp,
              color: product.stockQuantity > 0
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),

          SizedBox(height: 24.h),

          // Quantity selector
          Row(
            children: [
              Text('Quantité:', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 16.w),
              SizedBox(
                width: 100.w,
                child: TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: product.stockQuantity > 0
                  ? () {
                      final quantity =
                          int.tryParse(quantityController.text) ?? 1;
                      if (quantity > 0) {
                        controller.addToCart(product, quantity);
                        Get.back();
                      }
                    }
                  : null,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(AppStrings.addToCart),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkProductSheet(
    BuildContext context,
    Rxn<ProductPortion> selectedPortion,
    TextEditingController quantityController,
  ) {
    final portions = controller.getPortionsForProduct(product.id!);

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name with bulk indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Produit en vrac',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Description
          if (product.description != null)
            Text(
              product.description!,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),

          SizedBox(height: 8.h),

          // Bulk product info
          if (product.bulkUnit != null && product.bulkTotalQuantity != null)
            Text(
              'Contenance: ${product.bulkTotalQuantity} ${product.bulkUnit}',
              style: TextStyle(
                fontSize: 13.sp,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),

          SizedBox(height: 16.h),

          // Stock
          Text(
            'Stock disponible: ${product.stockQuantity} ${product.bulkUnit ?? "unité(s)"}',
            style: TextStyle(
              fontSize: 14.sp,
              color: product.stockQuantity > 0
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),

          SizedBox(height: 16.h),

          // Portions list
          Text(
            'Choisissez une portion:',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 12.h),

          if (portions.isEmpty)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Aucune portion disponible pour ce produit',
                style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              ),
            )
          else
            ...portions
                .where((p) => p.isActive)
                .map(
                  (portion) => Obx(() {
                    final isSelected = selectedPortion.value?.id == portion.id;
                    return InkWell(
                      onTap: () => selectedPortion.value = portion,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surface,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    portion.name,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${portion.quantity} ${product.bulkUnit ?? ""}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${portion.price.toStringAsFixed(2)} €',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

          SizedBox(height: 24.h),

          // Quantity selector (only if portion selected)
          Obx(() {
            if (selectedPortion.value == null) return const SizedBox.shrink();

            return Column(
              children: [
                Row(
                  children: [
                    Text('Quantité:', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 16.w),
                    SizedBox(
                      width: 100.w,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),

          // Add to cart button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed:
                    (product.stockQuantity > 0 && selectedPortion.value != null)
                    ? () {
                        final quantity =
                            int.tryParse(quantityController.text) ?? 1;
                        if (quantity > 0) {
                          controller.addToCart(
                            product,
                            quantity,
                            productPortionId: selectedPortion.value?.id,
                          );
                          Get.back();
                        }
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  selectedPortion.value == null
                      ? 'Sélectionnez une portion'
                      : AppStrings.addToCart,
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
        ],
      ),
    );
  }
}
