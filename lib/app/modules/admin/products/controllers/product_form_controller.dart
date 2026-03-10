import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/product_portion_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../core/values/app_strings.dart';
import 'products_controller.dart';

class ProductFormController extends GetxController {
  final ProductRepository _productRepository = Get.find();
  final ProductPortionRepository _portionRepository = Get.find();
  final CategoryRepository _categoryRepository = Get.find();

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockQuantityController = TextEditingController();
  final minStockAlertController = TextEditingController();
  final bulkUnitController = TextEditingController();
  final bulkTotalQuantityController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isEdit = false.obs;
  final categories = <ProductCategory>[].obs;
  final selectedCategory = Rxn<int>();
  final isActive = true.obs;
  final isBulkProduct = false.obs;

  // Portions management
  final portions = <PortionData>[].obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  Product? productToEdit;

  @override
  void onInit() {
    super.onInit();
    loadCategories();

    // Check if editing
    final args = Get.arguments;
    if (args != null) {
      isEdit.value = args['isEdit'] ?? false;
      productToEdit = args['product'];

      if (productToEdit != null) {
        nameController.text = productToEdit!.name;
        descriptionController.text = productToEdit!.description ?? '';
        priceController.text = productToEdit!.price.toString();
        stockQuantityController.text = productToEdit!.stockQuantity.toString();
        minStockAlertController.text = productToEdit!.minStockAlert.toString();
        selectedCategory.value = productToEdit!.categoryId;
        isActive.value = productToEdit!.isActive;
        isBulkProduct.value = productToEdit!.isBulkProduct;

        if (productToEdit!.isBulkProduct) {
          bulkUnitController.text = productToEdit!.bulkUnit ?? '';
          bulkTotalQuantityController.text =
              productToEdit!.bulkTotalQuantity?.toString() ?? '';

          // Load portions for this product
          loadPortions();
        }
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockQuantityController.dispose();
    minStockAlertController.dispose();
    bulkUnitController.dispose();
    bulkTotalQuantityController.dispose();
    super.onClose();
  }

  /// Load portions for the product
  Future<void> loadPortions() async {
    if (productToEdit == null || !productToEdit!.isBulkProduct) return;

    try {
      final result = await _portionRepository.getProductPortions(
        productToEdit!.id!,
      );

      portions.value = result
          .map(
            (p) => PortionData(
              id: p.id,
              name: p.name,
              quantity: p.quantity,
              price: p.price,
            ),
          )
          .toList();
    } catch (e) {
      print('Load portions error: $e');
    }
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      final result = await _categoryRepository.getAllCategories(
        forceRefresh: true,
      );
      categories.value = List<ProductCategory>.from(result);
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les catégories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Validate and submit form
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une catégorie',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate bulk product fields
    if (isBulkProduct.value) {
      if (bulkUnitController.text.trim().isEmpty) {
        Get.snackbar(
          'Erreur',
          'L\'unité est requise pour un produit en vrac',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final bulkQty = double.tryParse(bulkTotalQuantityController.text);
      if (bulkQty == null || bulkQty <= 0) {
        Get.snackbar(
          'Erreur',
          'La quantité totale doit être positive',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (portions.isEmpty) {
        Get.snackbar(
          'Erreur',
          'Veuillez ajouter au moins une portion pour ce produit en vrac',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    try {
      isLoading.value = true;

      final price = double.parse(priceController.text);
      final stockQuantity = int.parse(stockQuantityController.text);
      final minStockAlert = int.parse(minStockAlertController.text);

      final bulkUnit = isBulkProduct.value
          ? bulkUnitController.text.trim()
          : null;
      final bulkTotalQuantity = isBulkProduct.value
          ? double.parse(bulkTotalQuantityController.text)
          : null;

      if (isEdit.value && productToEdit != null) {
        // Update product
        await _productRepository.updateProduct(
          productId: productToEdit!.id!,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          price: price,
          categoryId: selectedCategory.value!,
          minStockAlert: minStockAlert,
          stockQuantity: stockQuantity,
          isBulkProduct: isBulkProduct.value,
          bulkUnit: bulkUnit,
          bulkTotalQuantity: bulkTotalQuantity,
        );

        // Update portions if bulk product
        if (isBulkProduct.value) {
          await _updatePortions(productToEdit!.id!);
        }

        // Reload products list
        try {
          Get.find<ProductsController>().loadData();
        } catch (e) {
          // ProductsController might not be in memory, ignore
        }

        // Return to previous screen
        Get.back(result: true);

        // Show success message
        Get.snackbar(
          'Succès',
          AppStrings.successUpdate,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create product
        final newProduct = await _productRepository.createProduct(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          price: price,
          categoryId: selectedCategory.value!,
          stockQuantity: stockQuantity,
          minStockAlert: minStockAlert,
          isBulkProduct: isBulkProduct.value,
          bulkUnit: bulkUnit,
          bulkTotalQuantity: bulkTotalQuantity,
        );

        // Create portions if bulk product
        if (isBulkProduct.value && newProduct.id != null) {
          await _createPortions(newProduct.id!);
        }

        // Reload products list
        try {
          Get.find<ProductsController>().loadData();
        } catch (e) {
          // ProductsController might not be in memory, ignore
        }

        // Return to previous screen
        Get.back(result: true);

        // Show success message
        Get.snackbar(
          'Succès',
          'Produit créé avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le produit: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Create portions for a new product
  Future<void> _createPortions(int productId) async {
    for (var i = 0; i < portions.length; i++) {
      final p = portions[i];
      await _portionRepository.createPortion(
        productId: productId,
        name: p.name,
        quantity: p.quantity,
        price: p.price,
        displayOrder: i,
      );
    }
  }

  /// Update portions for existing product
  Future<void> _updatePortions(int productId) async {
    // For simplicity, we'll delete all existing portions and create new ones
    // In a production app, you might want to update them individually
    try {
      final existing = await _portionRepository.getProductPortions(productId);

      // Delete existing portions
      for (var portion in existing) {
        if (portion.id != null) {
          await _portionRepository.deletePortion(portion.id!);
        }
      }

      // Create new portions
      await _createPortions(productId);
    } catch (e) {
      print('Update portions error: $e');
      rethrow;
    }
  }

  /// Add a new portion
  void addPortion(String name, double quantity, double price) {
    portions.add(PortionData(name: name, quantity: quantity, price: price));
  }

  /// Remove a portion
  void removePortion(int index) {
    portions.removeAt(index);
  }

  /// Show dialog to add/edit portion
  Future<void> showPortionDialog({int? index}) async {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    if (index != null) {
      final portion = portions[index];
      nameCtrl.text = portion.name;
      quantityCtrl.text = portion.quantity.toString();
      priceCtrl.text = portion.price.toString();
    }

    return Get.dialog(
      AlertDialog(
        title: Text(
          index == null ? 'Ajouter une portion' : 'Modifier la portion',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom (ex: 25cl, 33cl, 50cl)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityCtrl,
              decoration: InputDecoration(
                labelText: 'Quantité en ${bulkUnitController.text}',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Prix (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final quantity = double.tryParse(quantityCtrl.text);
              final price = double.tryParse(priceCtrl.text);

              if (name.isEmpty || quantity == null || price == null) {
                Get.snackbar(
                  'Erreur',
                  'Veuillez remplir tous les champs correctement',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (index == null) {
                addPortion(name, quantity, price);
              } else {
                portions[index] = PortionData(
                  id: portions[index].id,
                  name: name,
                  quantity: quantity,
                  price: price,
                );
              }

              Get.back();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }
    return null;
  }

  /// Validate price
  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Prix requis';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Prix invalide';
    }
    // For bulk products, price can be 0 (portions define the prices)
    if (!isBulkProduct.value && price <= 0) {
      return 'Prix doit être positif';
    }
    return null;
  }

  /// Validate stock
  String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantité requise';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Quantité invalide';
    }
    return null;
  }

  /// Validate min stock alert
  String? validateMinStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Seuil requis';
    }
    final minStock = int.tryParse(value);
    if (minStock == null || minStock < 0) {
      return 'Seuil invalide';
    }
    return null;
  }
}

/// Data class for managing portions in the form
class PortionData {
  final int? id;
  final String name;
  final double quantity;
  final double price;

  PortionData({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });
}
