import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/values/app_strings.dart';
import 'app/data/providers/serverpod_client_provider.dart';
import 'app/data/repositories/user_repository.dart';
import 'app/data/repositories/product_repository.dart';
import 'app/data/repositories/product_portion_repository.dart';
import 'app/data/repositories/category_repository.dart';
import 'app/data/repositories/cart_repository.dart';
import 'app/data/repositories/transaction_repository.dart';
import 'app/data/repositories/stock_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/auth_service.dart';
import 'app/services/connectivity_service.dart';
import 'app/services/storage_service.dart';
import 'app/services/server_config_service.dart';

/// Point d'entrée de l'application AirBar
///
/// Initialise tous les services et repositories GetX nécessaires au
/// fonctionnement de l'application avant le lancement de l'UI.
///
/// Ordre d'initialisation (IMPORTANT):
/// 1. StorageService - Stockage local (GetStorage)
/// 2. ServerConfigService - Configuration serveur Serverpod
/// 3. ServerpodClientProvider - Client API Serverpod
/// 4. AuthService - Service d'authentification
/// 5. ConnectivityService - Surveillance de la connexion réseau
/// 6. Repositories - Couche d'accès aux données
///
/// L'ordre est crucial car certains services dépendent d'autres
/// (ex: ServerpodClient dépend de ServerConfigService).
void main() async {
  // Initialisation obligatoire avant tout appel async
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Services de base (stockage local et configuration serveur)
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ServerConfigService().init());

  // 2. Initialisation du client Serverpod avec la config sauvegardée
  await ServerpodClientProvider.initialize();

  // 3. Services globaux (authentification et connectivité)
  Get.put(AuthService());
  Get.put(ConnectivityService());

  // 4. Repositories (couche d'accès aux données)
  // Enregistrés en permanent pour être partagés entre tous les modules
  Get.put(UserRepository());
  Get.put(ProductRepository());
  Get.put(ProductPortionRepository());
  Get.put(CategoryRepository());
  Get.put(CartRepository());
  Get.put(TransactionRepository());
  Get.put(StockRepository());

  // 5. Lancement de l'application
  runApp(const MyApp());
}

/// Widget racine de l'application AirBar
///
/// Configure:
/// - ScreenUtilInit: Design responsive basé sur 1024x768 (tablette)
/// - GetMaterialApp: Navigation GetX + thèmes + routes
/// - Route initiale: SPLASH (redirection auto vers login ou home)
///
/// Thèmes:
/// - Light theme: Thème clair avec couleurs AirBar
/// - Dark theme: Disponible mais non activé par défaut
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1024, 768), // Taille de référence (tablette)
      minTextAdapt: true, // Adaptation minimale du texte
      splitScreenMode: true, // Support du mode écran partagé
      builder: (context, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          theme: AppTheme.lightTheme, // Thème clair
          darkTheme: AppTheme.darkTheme, // Thème sombre (non utilisé)
          themeMode: ThemeMode.light, // Mode clair forcé
          initialRoute: AppRoutes.SPLASH, // Route de démarrage
          getPages: AppPages.routes, // Définition de toutes les routes
          debugShowCheckedModeBanner: false, // Masquer le bandeau debug
        );
      },
    );
  }
}

/// Extension pour les services GetX
///
/// Permet d'utiliser la syntaxe async/await avec Get.putAsync
/// en forçant les services à se comporter comme des Future<T>.
///
/// Exemple d'utilisation:
/// ```dart
/// await Get.putAsync(() => StorageService().init());
/// ```
extension ServiceInit<T extends GetxService> on T {
  /// Initialise le service et retourne le service lui-même
  ///
  /// Permet le chainage avec Get.putAsync pour une initialisation async.
  Future<T> init() async {
    onInit(); // Appel du lifecycle GetxService
    return this; // Retour du service pour GetX
  }
}
