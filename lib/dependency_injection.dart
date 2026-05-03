import 'package:get/get.dart';

import 'core/auth/auth_session.dart';
import 'core/network/api_client.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/distributor_remote_datasource.dart';
import 'data/datasources/enquiry_remote_datasource.dart';
import 'data/datasources/order_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/distributor_repository_impl.dart';
import 'data/repositories/enquiry_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/distributor_repository.dart';
import 'domain/repositories/enquiry_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'presentation/controllers/cart_controller.dart';
import 'presentation/controllers/dashboard_controller.dart';
import 'presentation/controllers/distributor_controller.dart';
import 'presentation/controllers/enquiry_controller.dart';
import 'presentation/controllers/login_controller.dart';
import 'presentation/controllers/register_controller.dart';
import 'presentation/controllers/order_controller.dart';
import 'presentation/controllers/product_controller.dart';

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    await Get.putAsync(() async {
      final session = AuthSession();
      await session.init();
      return session;
    });

    Get.put<ApiClient>(
      ApiClient(authSession: Get.find<AuthSession>()),
      permanent: true,
    );

    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl(
        apiClient: Get.find(),
        authSession: Get.find(),
      ),
      permanent: true,
    );
    Get.put<ProductRemoteDataSource>(
      ProductRemoteDataSourceImpl(apiClient: Get.find()),
      permanent: true,
    );
    Get.put<OrderRemoteDataSource>(
      OrderRemoteDataSourceImpl(apiClient: Get.find()),
      permanent: true,
    );
    Get.put<DistributorRemoteDataSource>(
      DistributorRemoteDataSourceImpl(apiClient: Get.find()),
      permanent: true,
    );
    Get.put<EnquiryRemoteDataSource>(
      EnquiryRemoteDataSourceImpl(apiClient: Get.find()),
      permanent: true,
    );

    Get.put<AuthRepository>(
      AuthRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );
    Get.put<ProductRepository>(
      ProductRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );
    Get.put<OrderRepository>(
      OrderRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );
    Get.put<DistributorRepository>(
      DistributorRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );
    Get.put<EnquiryRepository>(
      EnquiryRepositoryImpl(remoteDataSource: Get.find()),
      permanent: true,
    );

    Get.put<CartController>(CartController(), permanent: true);
  }

  static void bindLogin() {
    if (!Get.isRegistered<LoginController>()) {
      Get.lazyPut(() => LoginController(repository: Get.find(), authSession: Get.find()));
    }
  }

  static void bindRegister() {
    if (!Get.isRegistered<RegisterController>()) {
      Get.lazyPut(() => RegisterController(repository: Get.find()));
    }
  }

  static void bindDashboard() {
    if (!Get.isRegistered<DashboardController>()) {
      Get.lazyPut(() => DashboardController(
            orderRepository: Get.find(),
            productRepository: Get.find(),
            enquiryRepository: Get.find(),
          ));
    }
  }

  static void bindProducts() {
    if (!Get.isRegistered<ProductController>()) {
      Get.lazyPut(() => ProductController(repository: Get.find()));
    }
  }

  static void bindOrders() {
    if (!Get.isRegistered<OrderController>()) {
      Get.lazyPut(() => OrderController(repository: Get.find()));
    }
  }

  static void bindDistributor() {
    if (!Get.isRegistered<DistributorController>()) {
      Get.lazyPut(() => DistributorController(repository: Get.find()));
    }
  }

  static void bindEnquiry() {
    if (!Get.isRegistered<EnquiryController>()) {
      Get.lazyPut(() => EnquiryController(repository: Get.find()));
    }
  }
}
