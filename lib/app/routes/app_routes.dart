abstract class AppRoutes {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const SERVER_CONFIG = '/server-config';

  // User routes
  static const USER_HOME = '/user';
  static const USER_SHOP = '/user/shop';
  static const USER_CART = '/user/cart';
  static const USER_CHECKOUT = '/user/checkout';
  static const USER_ACCOUNT = '/user/account';
  static const USER_HISTORY = '/user/history';

  // Admin routes
  static const ADMIN_DASHBOARD = '/admin';
  static const ADMIN_USERS = '/admin/users';
  static const ADMIN_USER_FORM = '/admin/users/form';
  static const ADMIN_USER_CREDIT = '/admin/users/credit';
  static const ADMIN_PRODUCTS = '/admin/products';
  static const ADMIN_PRODUCT_FORM = '/admin/products/form';
  static const ADMIN_CATEGORIES = '/admin/categories';
  static const ADMIN_CATEGORY_FORM = '/admin/categories/form';
  static const ADMIN_STOCK = '/admin/stock';
  static const ADMIN_STOCK_RESTOCK = '/admin/stock/restock';
  static const ADMIN_TRANSACTIONS = '/admin/transactions';
  static const ADMIN_EXPORT = '/admin/export';
}
