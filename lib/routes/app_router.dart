import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ph_virchowrx/presentation/pages/cart/place_order_screen.dart';
import 'package:ph_virchowrx/presentation/pages/products/product_gallery_screen.dart';
import 'package:ph_virchowrx/presentation/pages/products/product_info_screen.dart';
import '../core/auth/auth_session.dart';
import '../core/constants/app_routes.dart';
import '../domain/entities/product_entity.dart';
import '../dependency_injection.dart';
import '../presentation/pages/cart/cart_page.dart';
import '../presentation/pages/dashboard/dashboard_page.dart';
import '../presentation/pages/distributor/distributor_page.dart';
import '../presentation/pages/enquiry/enquiry_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/register/pharmacy_register_page.dart';
import '../presentation/pages/orders/orders_page.dart';
import '../presentation/pages/products/product_details.dart';
import '../presentation/pages/products/products_page.dart';

class AppRouter {
  AppRouter._();

  static String _computeInitialLocation() {
    try {
      final session = Get.find<AuthSession>();
      return session.token.value.isNotEmpty ? AppRoutes.dashboard : AppRoutes.login;
    } catch (_) {
      return AppRoutes.login;
    }
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    try {
      final loggedIn = Get.find<AuthSession>().token.value.isNotEmpty;
      final loc = state.matchedLocation;
      final onPublicAuth = loc == AppRoutes.login || loc == AppRoutes.register;

      if (!loggedIn && !onPublicAuth) {
        return AppRoutes.login;
      }
      if (loggedIn && onPublicAuth) {
        return AppRoutes.products;
      }
      return null;
    } catch (_) {
      return AppRoutes.login;
    }
  }

  static final GoRouter router = GoRouter(
    initialLocation: _computeInitialLocation(),
    refreshListenable: Get.find<AuthSession>().authListenable,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (_, __) {
          try {
            final loggedIn = Get.find<AuthSession>().token.value.isNotEmpty;
            return loggedIn ? AppRoutes.products : AppRoutes.login;
          } catch (_) {
            return AppRoutes.login;
          }
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          DependencyInjection.bindRegister();
          return const PharmacyRegisterPage();
        },
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
          DependencyInjection.bindLogin();
          return const ProductsPage();
        },
      ),
      GoRoute(
        path: AppRoutes.findDistributor,
        builder: (context, state) {
          DependencyInjection.bindDistributor();
          return const DistributorsListScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) {
          DependencyInjection.bindOrders();
          return const MyOrdersScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.enquiry,
        builder: (context, state) {
          DependencyInjection.bindEnquiry();
          return const EnquiryScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        builder: (context, state) => const CartScreen(),
      ),
      // app_router.dart
      GoRoute(
        path: AppRoutes.productDetail, // Ensure this matches AppRoutes.productDetail
        builder: (context, state) {
          final product = state.extra;
          String? id;
          if (product is ProductEntity) id = product.id;
          id ??= state.pathParameters['id'];
          return ProductDetailScreen(
            key: ValueKey('product_detail_${id ?? 'unknown'}'),
            product: product,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.productInfo, // Ensure this matches AppRoutes.productDetail
        builder: (context, state) {
          // Retrieve the product passed via 'extra'
          final product = state.extra;
          return ProductInfoScreen(product: product);
        },
      ),

      GoRoute(
        path: AppRoutes.productGallery, // Ensure this matches AppRoutes.productDetail
        builder: (context, state) {
          // Retrieve the product passed via 'extra'
          final product = state.extra;
          return ProductGalleryScreen(product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.placeOrderScreen,
        builder: (context, state) => const PlaceOrderScreen(),
      ),
    ],
  );
}