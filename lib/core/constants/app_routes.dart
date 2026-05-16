class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordConfirm = '/forgot-password/confirm';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  /// Route pattern for [GoRoute]; use [productDetailPath] when calling [context.push].
  static const String productDetail = '/products/:id';

  /// Navigate with the real catalog id, e.g. `/products/42` (required for correct routing).
  static String productDetailPath(String productId) =>
      '/products/${Uri.encodeComponent(productId.trim())}';
  static const String findDistributor = '/find-distributor';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String enquiry = '/enquiry';
  static const String enquiryDetail = '/enquiry/:id';
  static const String newEnquiry = '/enquiry/new';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String settings = '/settings';
  static const String productDetails = '/product-detail';
  static const String productInfo = '/product-info';
  static const String productGallery = '/product-gallery';
  static const String placeOrderScreen = '/place-order';
}