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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetX services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => ServerConfigService().init());

  // Initialize Serverpod client
  await ServerpodClientProvider.initialize();

  Get.put(AuthService());
  Get.put(ConnectivityService());

  // Initialize repositories
  Get.put(UserRepository());
  Get.put(ProductRepository());
  Get.put(ProductPortionRepository());
  Get.put(CategoryRepository());
  Get.put(CartRepository());
  Get.put(TransactionRepository());
  Get.put(StockRepository());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1024, 768), // Tablet size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: AppStrings.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Extension to ensure GetxService init returns the service
extension ServiceInit<T extends GetxService> on T {
  Future<T> init() async {
    onInit();
    return this;
  }
}
