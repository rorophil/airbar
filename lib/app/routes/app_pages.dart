import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/server_config_view.dart';
import '../modules/user/shop/bindings/shop_binding.dart';
import '../modules/user/shop/views/shop_view.dart';
import '../modules/user/cart/bindings/cart_binding.dart';
import '../modules/user/cart/views/cart_view.dart';
import '../modules/user/checkout/bindings/checkout_binding.dart';
import '../modules/user/checkout/views/checkout_view.dart';
import '../modules/admin/dashboard/bindings/dashboard_binding.dart';
import '../modules/admin/dashboard/views/dashboard_view.dart';
import '../modules/admin/users/bindings/users_binding.dart';
import '../modules/admin/users/views/users_view.dart';
import '../modules/admin/users/bindings/user_form_binding.dart';
import '../modules/admin/users/views/user_form_view.dart';
import '../modules/admin/users/bindings/user_credit_binding.dart';
import '../modules/admin/users/views/user_credit_view.dart';
import '../modules/admin/products/bindings/products_binding.dart';
import '../modules/admin/products/views/products_view.dart';
import '../modules/admin/products/bindings/product_form_binding.dart';
import '../modules/admin/products/views/product_form_view.dart';
import '../modules/admin/categories/bindings/categories_binding.dart';
import '../modules/admin/categories/views/categories_view.dart';
import '../modules/admin/categories/bindings/category_form_binding.dart';
import '../modules/admin/categories/views/category_form_view.dart';
import '../modules/admin/stock/bindings/stock_binding.dart';
import '../modules/admin/stock/views/stock_view.dart';
import '../modules/admin/stock/bindings/restock_binding.dart';
import '../modules/admin/stock/views/restock_view.dart';
import '../modules/admin/transactions/bindings/transactions_binding.dart';
import '../modules/admin/transactions/views/transactions_view.dart';
import '../modules/admin/export/bindings/export_binding.dart';
import '../modules/admin/export/views/export_view.dart';

class AppPages {
  static final routes = [
    // Splash
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),

    // Login
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // Server Config
    GetPage(
      name: AppRoutes.SERVER_CONFIG,
      page: () => const ServerConfigView(),
      binding: SettingsBinding(),
    ),

    // User Routes
    GetPage(
      name: AppRoutes.USER_SHOP,
      page: () => const ShopView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: AppRoutes.USER_CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.USER_CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),

    // Admin Routes
    GetPage(
      name: AppRoutes.ADMIN_DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_USERS,
      page: () => const UsersView(),
      binding: UsersBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_USER_FORM,
      page: () => const UserFormView(),
      binding: UserFormBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_USER_CREDIT,
      page: () => const UserCreditView(),
      binding: UserCreditBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_PRODUCTS,
      page: () => const ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_PRODUCT_FORM,
      page: () => const ProductFormView(),
      binding: ProductFormBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_CATEGORIES,
      page: () => const CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_CATEGORY_FORM,
      page: () => const CategoryFormView(),
      binding: CategoryFormBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STOCK,
      page: () => const StockView(),
      binding: StockBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STOCK_RESTOCK,
      page: () => const RestockView(),
      binding: RestockBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_TRANSACTIONS,
      page: () => const TransactionsView(),
      binding: TransactionsBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_EXPORT,
      page: () => const ExportView(),
      binding: ExportBinding(),
    ),
  ];
}
