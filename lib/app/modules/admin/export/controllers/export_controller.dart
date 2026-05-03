import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../utils/file_saver.dart' as file_saver;

/// Controller du module d'export de données (Admin)
///
/// Permet aux administrateurs d'exporter des données en CSV pour analyse externe.
///
/// Fonctionnalités principales:
/// - Export de transactions sur une période donnée
/// - Export de produits en stock faible/rupture
/// - Filtrage par type de transaction (optionnel)
/// - Génération de fichiers CSV avec nom explicite
/// - Support multi-plateforme (Web, Desktop, Mobile)
///
/// Export de transactions:
/// - Sélection de période (date début/fin)
/// - Filtrage optionnel par type (purchase/credit/refund)
/// - Colonnes CSV: ID, Date, Utilisateur, Type, Montant, Solde après, Notes
/// - Nom fichier: "Transactions du DD-MM-YYYY au DD-MM-YYYY.csv"
///
/// Export produits stock faible:
/// - Filtre automatique: trackStock = true ET (stock <= minStockAlert OU stock = 0)
/// - Support produits réguliers et en vrac
/// - Calcul stock total pour produits en vrac (unités complètes + unité entamée)
/// - Colonnes CSV: ID, Nom, Catégorie, Prix, Stock actuel, Seuil alerte, Unité, Statut
/// - Statut: "RUPTURE", "STOCK FAIBLE", "OK"
/// - Nom fichier: "Produits stock faible DD-MM-YYYY.csv"
///
/// Gestion multi-plateforme:
/// - Web: téléchargement automatique via blob
/// - Desktop/Mobile: sélection dossier puis sauvegarde
/// - FileSaver abstrait les différences (file_saver.dart)
///
/// Note: Les exports respectent le format CSV standard (séparateur virgule,
/// remplacement virgules par point-virgule dans les textes).
class ExportController extends GetxController {
  final TransactionRepository _transactionRepository = Get.find();
  final UserRepository _userRepository = Get.find();
  final ProductRepository _productRepository = Get.find();
  final CategoryRepository _categoryRepository = Get.find();

  // Observables
  final isExporting = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final selectedType = Rxn<TransactionType>();
  final users = <User>[].obs;
  final categories = <ProductCategory>[].obs;

  /// Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          startDate.value ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      startDate.value = picked;
    }
  }

  /// Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value ?? DateTime.now(),
      firstDate: startDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      endDate.value = picked;
    }
  }

  /// Select transaction type filter
  void selectType(TransactionType? type) {
    selectedType.value = type;
  }

  /// Export transactions
  Future<void> exportTransactions() async {
    print('=== DEBUG: exportTransactions called ===');

    if (startDate.value == null || endDate.value == null) {
      print('DEBUG: Missing dates');
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une période',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print('DEBUG: Start date: ${startDate.value}, End date: ${endDate.value}');

    try {
      isExporting.value = true;
      print('DEBUG: isExporting set to true');

      // Get transactions and users in parallel
      final results = await Future.wait([
        _transactionRepository.getAllTransactions(),
        _userRepository.getAllUsers(),
      ]);

      final List<Transaction> transactions = List<Transaction>.from(results[0]);
      users.value = List<User>.from(results[1]);
      print(
        'DEBUG: Loaded ${transactions.length} transactions and ${users.length} users',
      );

      // Filter by date range
      final List<Transaction> filteredByDate = transactions.where((t) {
        return t.timestamp.isAfter(startDate.value!) &&
            t.timestamp.isBefore(endDate.value!.add(const Duration(days: 1)));
      }).toList();
      print('DEBUG: Filtered by date: ${filteredByDate.length} transactions');

      // Filter by type if selected
      final List<Transaction> filtered = selectedType.value != null
          ? filteredByDate.where((t) => t.type == selectedType.value).toList()
          : filteredByDate;
      print('DEBUG: Final filtered: ${filtered.length} transactions');

      // Generate CSV content
      final csvContent = _generateCSV(filtered);
      print('DEBUG: CSV generated, length: ${csvContent.length} chars');

      // Generate filename
      final dateFormat = DateFormat('dd-MM-yyyy');
      final startDateStr = dateFormat.format(startDate.value!);
      final endDateStr = dateFormat.format(endDate.value!);
      final fileName = 'Transactions du $startDateStr au $endDateStr.csv';
      print('DEBUG: Filename: $fileName');

      // Save file
      print('DEBUG: Calling _saveFile...');
      final savedPath = await _saveFile(csvContent, fileName);
      print('DEBUG: _saveFile returned: $savedPath');

      if (savedPath != null) {
        Get.snackbar(
          'Succès',
          'Export terminé: ${filtered.length} transaction(s) exportée(s)\nFichier: $savedPath',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        print('DEBUG: savedPath is null (user cancelled)');
      }
      // Si savedPath == null, l'utilisateur a annulé, on n'affiche rien
    } catch (e, stackTrace) {
      print('DEBUG: Error occurred: $e');
      print('DEBUG: Stack trace: $stackTrace');
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les transactions: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
      print('DEBUG: isExporting set to false');
    }
  }

  /// Export products below stock alert threshold
  Future<void> exportLowStockProducts() async {
    print('=== DEBUG: exportLowStockProducts called ===');

    try {
      isExporting.value = true;
      print('DEBUG: isExporting set to true');

      // Get products and categories in parallel
      final results = await Future.wait([
        _productRepository.getAllProducts(forceRefresh: true),
        _categoryRepository.getAllCategories(forceRefresh: true),
      ]);

      final List<Product> allProducts = List<Product>.from(results[0]);
      categories.value = List<ProductCategory>.from(results[1]);
      print(
        'DEBUG: Loaded ${allProducts.length} products and ${categories.length} categories',
      );

      // Filter products: trackStock = true AND (stockQuantity <= minStockAlert OR stockQuantity = 0)
      final List<Product> lowStockProducts = allProducts.where((p) {
        if (!p.trackStock)
          return false; // Ignore products without stock tracking
        if (!p.isActive) return false; // Ignore inactive products

        // For bulk products, calculate total available stock
        if (p.isBulkProduct && p.bulkTotalQuantity != null) {
          final totalStock =
              (p.stockQuantity * p.bulkTotalQuantity!) +
              (p.currentUnitRemaining ?? 0);
          final alertThreshold = p.minStockAlert * p.bulkTotalQuantity!;
          return totalStock <= alertThreshold;
        }

        // For regular products
        return p.stockQuantity <= p.minStockAlert;
      }).toList();

      print(
        'DEBUG: Found ${lowStockProducts.length} products below stock alert',
      );

      if (lowStockProducts.isEmpty) {
        Get.snackbar(
          'Information',
          'Aucun produit sous le seuil d\'alerte',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Generate CSV content
      final csvContent = _generateProductsCSV(lowStockProducts);
      print('DEBUG: CSV generated, length: ${csvContent.length} chars');

      // Generate filename
      final dateFormat = DateFormat('dd-MM-yyyy');
      final dateStr = dateFormat.format(DateTime.now());
      final fileName = 'Produits stock faible $dateStr.csv';
      print('DEBUG: Filename: $fileName');

      // Save file
      print('DEBUG: Calling _saveFile...');
      final savedPath = await _saveFile(csvContent, fileName);
      print('DEBUG: _saveFile returned: $savedPath');

      if (savedPath != null) {
        Get.snackbar(
          'Succès',
          'Export terminé: ${lowStockProducts.length} produit(s) exporté(s)\nFichier: $savedPath',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      } else {
        print('DEBUG: savedPath is null (user cancelled)');
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error occurred: $e');
      print('DEBUG: Stack trace: $stackTrace');
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les produits: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isExporting.value = false;
      print('DEBUG: isExporting set to false');
    }
  }

  /// Generate CSV content for products
  String _generateProductsCSV(List<Product> products) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
      'ID,Nom,Catégorie,Prix,Stock Actuel,Seuil Alerte,Unité,Statut',
    );

    // Rows
    for (final product in products) {
      final categoryName = _getCategoryName(product.categoryId);

      // Calculate current stock display
      String currentStock;
      if (product.isBulkProduct && product.bulkTotalQuantity != null) {
        final totalStock =
            (product.stockQuantity * product.bulkTotalQuantity!) +
            (product.currentUnitRemaining ?? 0);
        currentStock =
            '${totalStock.toStringAsFixed(2)} ${product.bulkUnit ?? ""}';
      } else {
        currentStock = product.stockQuantity.toString();
      }

      // Alert threshold display
      String alertThreshold;
      if (product.isBulkProduct && product.bulkTotalQuantity != null) {
        final threshold = product.minStockAlert * product.bulkTotalQuantity!;
        alertThreshold =
            '${threshold.toStringAsFixed(2)} ${product.bulkUnit ?? ""}';
      } else {
        alertThreshold = product.minStockAlert.toString();
      }

      // Status
      String status;
      if (product.stockQuantity == 0) {
        status = 'RUPTURE';
      } else if (product.isBulkProduct && product.bulkTotalQuantity != null) {
        final totalStock =
            (product.stockQuantity * product.bulkTotalQuantity!) +
            (product.currentUnitRemaining ?? 0);
        final alertThresholdValue =
            product.minStockAlert * product.bulkTotalQuantity!;
        status = totalStock <= alertThresholdValue ? 'STOCK FAIBLE' : 'OK';
      } else {
        status = product.stockQuantity <= product.minStockAlert
            ? 'STOCK FAIBLE'
            : 'OK';
      }

      buffer.writeln(
        [
          product.id,
          product.name.replaceAll(',', ';'),
          categoryName.replaceAll(',', ';'),
          product.price.toStringAsFixed(2),
          currentStock,
          alertThreshold,
          product.isBulkProduct ? product.bulkUnit ?? '' : 'unités',
          status,
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Get category name by ID
  String _getCategoryName(int categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (category != null) {
      return category.name;
    }
    return 'Catégorie #$categoryId';
  }

  /// Generate CSV content
  String _generateCSV(List<Transaction> transactions) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('ID,Type,Montant,Utilisateur,Date,Notes');

    // Rows
    for (final transaction in transactions) {
      final userName = _getUserName(transaction.userId);
      buffer.writeln(
        [
          transaction.id,
          transaction.type.name,
          transaction.totalAmount,
          userName,
          transaction.timestamp.toIso8601String(),
          transaction.notes?.replaceAll(',', ';') ?? '',
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Get user name by ID
  String _getUserName(int userId) {
    final user = users.firstWhereOrNull((u) => u.id == userId);
    if (user != null) {
      return '${user.firstName} ${user.lastName}';
    }
    return 'Utilisateur #$userId';
  }

  /// Save CSV file
  /// Returns file path if saved successfully, null if user cancelled
  Future<String?> _saveFile(String content, String fileName) async {
    return await file_saver.saveFile(content, fileName);
  }

  /// Get transaction type label
  String getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return 'Achats';
      case TransactionType.credit:
        return 'Crédits';
      case TransactionType.refund:
        return 'Remboursements';
    }
  }
}
