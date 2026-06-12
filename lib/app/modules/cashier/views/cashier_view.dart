import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/cashier_controller.dart';
import '../../../core/values/app_colors.dart';

/// Vue principale du module Caisse
class CashierView extends GetView<CashierController> {
  const CashierView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Caisse'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: controller.goBackToDashboard,
            tooltip: 'Retour au dashboard',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // Partie gauche: Grille de produits
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Barre de recherche
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onChanged: controller.updateSearchQuery,
                    ),
                  ),

                  // Filtres catégories
                  if (controller.categories.isNotEmpty)
                    SizedBox(
                      height: 50.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        children: [
                          // Chip "Tous"
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Obx(
                              () => ChoiceChip(
                                label: const Text('Tous'),
                                selected:
                                    controller.selectedCategoryId.value == null,
                                onSelected: (_) =>
                                    controller.filterByCategory(null),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color:
                                      controller.selectedCategoryId.value ==
                                          null
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          // Chips des catégories
                          ...controller.categories.map(
                            (cat) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: Obx(
                                () => ChoiceChip(
                                  label: Text(cat.name),
                                  selected:
                                      controller.selectedCategoryId.value ==
                                      cat.id,
                                  onSelected: (_) =>
                                      controller.filterByCategory(cat.id),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color:
                                        controller.selectedCategoryId.value ==
                                            cat.id
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Grille de produits
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
            ),

            // Partie droite: Panier en temps réel
            Container(
              width: 300.w,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                children: [
                  // En-tête du panier
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Panier',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${controller.cashierCart.length} article(s)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Liste des articles
                  Expanded(
                    child: Obx(() {
                      if (controller.cashierCart.isEmpty) {
                        return Center(
                          child: Text(
                            'Panier vide',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: controller.cashierCart.length,
                        itemBuilder: (context, index) {
                          final item = controller.cashierCart[index];
                          return _buildCartItem(item, index);
                        },
                      );
                    }),
                  ),

                  // Total et boutons d'action
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${controller.total.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Boutons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.clearCart,
                                child: const Text('Vider'),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: controller.goToCheckout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                child: const Text('Valider la vente'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Construit un widget pour un article du panier
  ///
  /// [item] L'article à afficher ([CashSaleItem])
  /// [index] L'index de l'article dans la liste (pour modification/suppression)
  ///
  /// Affiche:
  /// - Nom d'affichage (avec portion si applicable)
  /// - Prix effectif
  /// - Contrôles de quantité: boutons -/+ et suppression
  ///
  /// Actions:
  /// - Bouton "-": Réduit la quantité (supprime si 0)
  /// - Bouton "+": Augmente la quantité
  /// - Bouton poubelle: Supprime l'article du panier
  Widget _buildCartItem(CashSaleItem item, int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.effectivePrice.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () =>
                    controller.updateQuantity(index, item.quantity - 1),
                iconSize: 20.sp,
              ),
              Text('${item.quantity}', style: TextStyle(fontSize: 14.sp)),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () =>
                    controller.updateQuantity(index, item.quantity + 1),
                iconSize: 20.sp,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => controller.removeFromCart(index),
                color: AppColors.error,
                iconSize: 20.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget de carte pour afficher un produit régulier (non en vrac)
///
/// Affiche:
/// - Icône du produit
/// - Nom et description
/// - Prix unitaire
/// - Stock disponible (si [trackStock] = true)
/// - Indicateur visuel de stock (vert/orange/rouge)
///
/// Au tap, ouvre une bottom sheet ([_ProductDetailsSheet]) pour sélectionner
/// la quantité à ajouter au panier.
///
/// Utilisation:
/// ```dart
/// if (!product.isBulkProduct) {
///   return _ProductCard(product: product);
/// }
/// ```
class _ProductCard extends GetView<CashierController> {
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
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.shopping_bag,
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
                        if (product.trackStock)
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
                color: (!product.trackStock || product.stockQuantity > 0)
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retourne la couleur appropriée selon le niveau de stock
  ///
  /// - Rouge ([AppColors.error]): Stock épuisé (0)
  /// - Orange: Stock faible (≤ seuil d'alerte)
  /// - Vert ([AppColors.success]): Stock OK (> seuil d'alerte)
  Color _getStockColor() {
    if (product.stockQuantity == 0) return AppColors.error;
    if (product.stockQuantity <= product.minStockAlert) return Colors.orange;
    return AppColors.success;
  }

  /// Affiche la bottom sheet de détails du produit
  ///
  /// Permet de sélectionner la quantité et d'ajouter au panier.
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

/// Widget de carte pour afficher un produit en vrac
///
/// Affiche:
/// - Badge "Produit en vrac"
/// - Nom du produit
/// - Contenance d'une unité (ex: 6L par fût)
/// - Stock disponible (nombre d'unités)
/// - Liste des portions actives (25cl, 50cl, etc.)
///
/// Chaque portion est cliquable et ouvre un dialog ([_showPortionDialog])
/// pour sélectionner la quantité à ajouter.
///
/// Les portions inactives ([isActive] = false) ne sont pas affichées.
///
/// Utilisation:
/// ```dart
/// if (product.isBulkProduct) {
///   return _BulkProductCard(product: product);
/// }
/// ```
class _BulkProductCard extends GetView<CashierController> {
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
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.local_drink,
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
                if (product.trackStock)
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
                  onTap: (!product.trackStock || product.stockQuantity > 0)
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
                              color:
                                  (!product.trackStock ||
                                      product.stockQuantity > 0)
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
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

  /// Retourne la couleur appropriée selon le niveau de stock
  ///
  /// - Rouge ([AppColors.error]): Stock épuisé (0)
  /// - Orange: Stock faible (≤ seuil d'alerte)
  /// - Vert ([AppColors.success]): Stock OK (> seuil d'alerte)
  Color _getStockColor() {
    if (product.stockQuantity == 0) return AppColors.error;
    if (product.stockQuantity <= product.minStockAlert) return Colors.orange;
    return AppColors.success;
  }

  /// Affiche un dialog pour ajouter une portion au panier
  ///
  /// [portion] La portion sélectionnée (ex: 25cl, 50cl)
  ///
  /// Le dialog affiche:
  /// - Nom de la portion
  /// - Prix de la portion
  /// - Quantité de la portion (ex: 0.25L)
  /// - Champ pour saisir le nombre de portions à commander
  ///
  /// Au clic sur "Ajouter au panier":
  /// 1. Ferme le dialog
  /// 2. Appelle [addToCashierCart] avec l'ID de la portion
  /// 3. Affiche un snackbar de confirmation
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
                Get.back();
                controller.addToCashierCart(
                  product,
                  quantity,
                  portionId: portion.id,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter au panier'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet de détails d'un produit
///
/// Affiche automatiquement la vue appropriée selon le type de produit:
/// - [_buildRegularProductSheet] pour les produits réguliers
/// - [_buildBulkProductSheet] pour les produits en vrac
///
/// Permet de sélectionner la quantité (et la portion pour les produits en vrac)
/// avant d'ajouter au panier.
///
/// Ouvert via [_ProductCard._showProductDetails] au tap sur une carte produit.
class _ProductDetailsSheet extends GetView<CashierController> {
  final Product product;

  const _ProductDetailsSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    final quantityController = TextEditingController(text: '1');
    final selectedPortion = Rxn<ProductPortion>();

    // For bulk products, show portions
    if (product.isBulkProduct) {
      return _buildBulkProductSheet(
        context,
        selectedPortion,
        quantityController,
      );
    }

    return _buildRegularProductSheet(context, quantityController);
  }

  /// Construit la sheet pour un produit régulier
  ///
  /// [quantityController] Controller pour le champ de saisie de quantité
  ///
  /// Affiche:
  /// - Nom et description du produit
  /// - Prix unitaire
  /// - Stock disponible (si [trackStock] = true)
  /// - Champ de saisie de quantité
  /// - Bouton "Ajouter au panier"
  ///
  /// Le bouton est désactivé si le stock est insuffisant.
  Widget _buildRegularProductSheet(
    BuildContext context,
    TextEditingController quantityController,
  ) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
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
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
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
            if (product.trackStock)
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
                onPressed: (!product.trackStock || product.stockQuantity > 0)
                    ? () {
                        final quantity =
                            int.tryParse(quantityController.text) ?? 1;
                        if (quantity > 0) {
                          Get.back();
                          controller.addToCashierCart(product, quantity);
                        }
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ajouter au panier'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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

  /// Construit la sheet pour un produit en vrac
  ///
  /// [selectedPortion] Portion actuellement sélectionnée (observable)
  /// [quantityController] Controller pour le champ de saisie de quantité
  ///
  /// Affiche:
  /// - Nom du produit avec badge "Produit en vrac"
  /// - Description et contenance
  /// - Stock disponible
  /// - Liste cliquable des portions disponibles
  /// - Champ de quantité (affiché seulement si portion sélectionnée)
  /// - Bouton "Ajouter au panier" (actif seulement si portion sélectionnée)
  ///
  /// Workflow:
  /// 1. Utilisateur sélectionne une portion (ex: 50cl)
  /// 2. Le champ de quantité apparaît
  /// 3. Le bouton devient actif
  /// 4. Au clic, ajoute au panier avec l'ID de la portion
  Widget _buildBulkProductSheet(
    BuildContext context,
    Rxn<ProductPortion> selectedPortion,
    TextEditingController quantityController,
  ) {
    final portions = controller.getPortionsForProduct(product.id!);

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SingleChildScrollView(
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
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
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
            if (product.trackStock)
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
                      final isSelected =
                          selectedPortion.value?.id == portion.id;
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
                                  : AppColors.textSecondary,
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
                      ((!product.trackStock || product.stockQuantity > 0) &&
                          selectedPortion.value != null)
                      ? () {
                          final quantity =
                              int.tryParse(quantityController.text) ?? 1;
                          if (quantity > 0) {
                            Get.back();
                            controller.addToCashierCart(
                              product,
                              quantity,
                              portionId: selectedPortion.value?.id,
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    selectedPortion.value == null
                        ? 'Sélectionnez une portion'
                        : 'Ajouter au panier',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
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
