import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_strings.dart';

/// Controller du module de gestion des produits (Admin)
///
/// Permet aux administrateurs de gérer le catalogue de produits du bar.
/// Support des produits réguliers et en vrac avec gestion de stock.
///
/// Fonctionnalités principales:
/// - Liste complète des produits avec recherche et filtres
/// - Création/modification de produits (réguliers ou en vrac)
/// - Activation/désactivation (soft delete) de produits
/// - Suppression définitive (isActive = false, préserve historique transactions)
/// - Filtrage par catégorie et recherche textuelle
/// - Gestion du stock directe (ajustement rapide)
///
/// Types de produits supportés:
/// - Produits réguliers: quantité entière (ex: bouteille, canette)
/// - Produits en vrac: portions multiples (ex: bière pression 25cl/50cl)
/// - Produits sans gestion de stock (trackStock = false)
///
/// Règles métier:
/// - Soft delete: isActive = false (produit masqué mais préservé)
/// - Hard delete impossible (protection historique transactions)
/// - Produits inactifs: visibles admin, invisibles boutique utilisateur
/// - Filtrage temps réel par nom, description, catégorie
class ProductsController extends GetxController {
  final ProductRepository _productRepository = Get.find();
  final CategoryRepository _categoryRepository = Get.find();

  // Text editing controller for search bar
  final searchController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final products = <Product>[].obs;
  final categories = <ProductCategory>[].obs;
  final searchQuery = ''.obs;
  final selectedCategoryId = Rxn<int>();
  final filteredProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Load products and categories
  Future<void> loadData() async {
    try {
      isLoading.value = true;

      final results = await Future.wait([
        _productRepository.getAllProducts(forceRefresh: true),
        _categoryRepository.getAllCategories(forceRefresh: true),
      ]);

      products.assignAll(List<Product>.from(results[0]));
      categories.assignAll(List<ProductCategory>.from(results[1]));

      filterProducts();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les produits: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter products
  void filterProducts() {
    var result = products.toList();

    // Filter by category
    if (selectedCategoryId.value != null) {
      result = result
          .where((p) => p.categoryId == selectedCategoryId.value)
          .toList();
    }

    // Filter by search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    filteredProducts.assignAll(result);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterProducts();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    filterProducts();
  }

  /// Select category filter
  void selectCategory(int? categoryId) {
    selectedCategoryId.value = categoryId;
    filterProducts();
  }

  /// Navigate to create product
  void createProduct() async {
    final result = await Get.toNamed(AppRoutes.ADMIN_PRODUCT_FORM);
    if (result == true) {
      loadData();
    }
  }

  /// Navigate to edit product
  void editProduct(Product product) async {
    final result = await Get.toNamed(
      AppRoutes.ADMIN_PRODUCT_FORM,
      arguments: {'product': product, 'isEdit': true},
    );
    if (result == true) {
      loadData();
    }
  }

  /// Delete product (soft delete)
  Future<void> deleteProduct(Product product) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer définitivement'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${product.name}" de la liste ?\n\n⚠️ Le produit sera retiré de la liste mais restera dans la base de données pour l\'historique des transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productRepository.deleteProduct(product.id!);

        Get.snackbar(
          'Succès',
          'Produit supprimé de la liste',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await loadData();
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer le produit: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Toggle product active status (activate/deactivate)
  Future<void> toggleActiveStatus(Product product) async {
    final isActivating = !product.isActive;
    final action = isActivating ? 'réactiver' : 'désactiver';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          isActivating ? 'Réactiver le produit' : 'Désactiver le produit',
        ),
        content: Text(
          'Êtes-vous sûr de vouloir $action "${product.name}" ?\n\n' +
              (isActivating
                  ? 'Le produit redeviendra visible dans la boutique.'
                  : 'Le produit sera masqué de la boutique mais pourra être réactivé.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              isActivating ? 'Réactiver' : 'Désactiver',
              style: TextStyle(
                color: isActivating ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productRepository.toggleActiveStatus(product.id!, isActivating);

        Get.snackbar(
          'Succès',
          isActivating ? 'Produit réactivé' : 'Produit désactivé',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await loadData();
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de modifier le statut: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Manage product stock
  Future<void> manageStock(Product product) async {
    final TextEditingController stockController = TextEditingController(
      text: product.stockQuantity.toString(),
    );

    final result = await Get.dialog<int>(
      AlertDialog(
        title: Text('Gérer le stock - ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stock actuel: ${product.stockQuantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nouvelle quantité',
                border: OutlineInputBorder(),
                hintText: 'Entrez la nouvelle quantité',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final current =
                        int.tryParse(stockController.text) ??
                        product.stockQuantity;
                    stockController.text = (current - 10).toString();
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('-10'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final current =
                        int.tryParse(stockController.text) ??
                        product.stockQuantity;
                    stockController.text = (current + 10).toString();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('+10'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                Get.back(result: newStock);
              } else {
                Get.snackbar(
                  'Erreur',
                  'Veuillez entrer une quantité valide (≥ 0)',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await _productRepository.updateStock(product.id!, result);

        Get.snackbar(
          'Succès',
          'Stock mis à jour: ${product.stockQuantity} → $result',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await loadData();
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de mettre à jour le stock: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await loadData();
  }

  /// Get category name by ID
  String getCategoryName(int categoryId) {
    try {
      final category = categories.firstWhere((c) => c.id == categoryId);
      return category.name;
    } catch (e) {
      return 'N/A';
    }
  }
}
