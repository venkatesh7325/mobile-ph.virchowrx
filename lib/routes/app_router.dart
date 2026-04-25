import 'package:go_router/go_router.dart';
import '../core/constants/app_routes.dart';
import '../dependency_injection.dart';
import '../presentation/pages/cart/cart_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/distributor/distributor_page.dart';
import '../presentation/pages/enquiry/enquiry_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/orders/orders_page.dart';
import '../presentation/pages/products/products_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) {
          DependencyInjection.bindDashboard();
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) {
          DependencyInjection.bindProducts();
          return const ProductsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.findDistributor,
        builder: (context, state) {
          DependencyInjection.bindDistributor();
          return const FindDistributorPage();
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) {
          DependencyInjection.bindOrders();
          return const OrdersPage();
        },
      ),
      GoRoute(
        path: AppRoutes.enquiry,
        builder: (context, state) {
          DependencyInjection.bindEnquiry();
          return const EnquiryPage();
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartPage(),
      ),
    ],
  );
}