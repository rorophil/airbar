import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/stock_controller.dart';
import '../../../../core/values/app_colors.dart';

/// Vue du module de gestion du stock (Admin)
///
/// Interface de suivi et gestion du stock des produits.
///
/// Composants principaux:
/// - AppBar: Titre "Gestion du stock"
/// - Champ de recherche: filtre par nom produit
/// - Section alertes: produits en stock faible/rupture
/// - Liste complète: tous les produits avec leur stock
///
/// Section alertes stock (en haut):
/// - Card rouge/orange si produits en alerte
/// - Liste des produits: stock <= minStockAlert
/// - Bouton "Réapprovisionner" par produit
/// - Affichage stock actuel vs seuil d'alerte
///
/// Liste complète des produits:
/// - Nom du produit
/// - Stock actuel avec badge coloré:
///   * Vert: stock OK (> minStockAlert)
///   * Orange: stock faible (<= minStockAlert)
///   * Rouge: rupture (= 0)
///   * Gris "N/A": stock non géré (trackStock = false)
/// - Bouton "Réapprovisionner" (si trackStock = true)
/// - Bouton "Info" pour produits sans gestion de stock
///
/// Support produits en vrac:
/// - Affichage stock total = (unités × capacité) + unité entamée
/// - Exemple: "34.25 litres" au lieu de "5 fûts"
/// - Seuil d'alerte calculé proportionnellement
///
/// Actions:
/// - Tap "Réapprovisionner" → Navigation RestockView
/// - Recherche → Filtrage instantané
/// - Pull to refresh → Rechargement données
class StockView extends GetView<StockController> {
  const StockView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du stock'),
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
                  hintText: 'Rechercher un produit...',
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

            // Low stock alert banner
            Obx(() {
              if (controller.lowStockProducts.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFFF9800), width: 1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: const Color(0xFFFF9800),
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        '${controller.lowStockProducts.length} produit(s) en stock faible',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFFFF9800),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

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
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredProducts[index];
                      return _StockCard(
                        product: product,
                        onRestock: () => controller.restockProduct(product),
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

class _StockCard extends GetView<StockController> {
  final Product product;
  final VoidCallback onRestock;

  const _StockCard({required this.product, required this.onRestock});

  @override
  Widget build(BuildContext context) {
    final stockColor = controller.getStockColor(product);
    final stockStatus = controller.getStockStatus(product);

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
                // Product icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.local_drink,
                    size: 30.sp,
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
                      if (product.description != null &&
                          product.description!.isNotEmpty)
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Stock info
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantité actuelle',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 20.sp,
                              color: stockColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${product.stockQuantity}',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: stockColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: stockColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            stockStatus,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: product.trackStock
                          ? AppColors.background
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: product.trackStock
                            ? AppColors.textHint
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seuil d\'alerte',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: product.trackStock
                                ? AppColors.textSecondary
                                : Colors.grey[400],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 20.sp,
                              color: product.trackStock
                                  ? AppColors.textHint
                                  : Colors.grey[300],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              product.trackStock
                                  ? '${product.minStockAlert}'
                                  : 'N/A',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: product.trackStock
                                    ? AppColors.textPrimary
                                    : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Restock button or disabled message
            if (!product.trackStock)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Gestion de stock désactivée pour ce produit',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRestock,
                  icon: const Icon(Icons.add_box),
                  label: const Text('Réapprovisionner'),
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
      ),
    );
  }
}
