import 'package:get/get.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/enquiry_repository.dart';
import '../../core/errors/failures.dart';

class DashboardController extends GetxController {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;
  final EnquiryRepository enquiryRepository;

  DashboardController({
    required this.orderRepository,
    required this.productRepository,
    required this.enquiryRepository,
  });

  final isLoading = false.obs;
  final errorMessage = RxnString();

  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final totalRevenue = 0.0.obs;
  final activeProducts = 0.obs;
  final pendingEnquiries = 0.obs;
  final recentOrders = <OrderEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final results = await Future.wait([
        orderRepository.getOrders(),
        productRepository.getProducts(),
        enquiryRepository.getEnquiries(),
      ]);

      results[0].fold(
        (f) => _handleFailure(f),
        (orders) {
          final list = orders as List<OrderEntity>;
          totalOrders.value = list.length;
          pendingOrders.value = list.where((o) => o.status == OrderStatus.pending).length;
          totalRevenue.value = list.fold(0.0, (sum, o) => sum + o.total);
          recentOrders.value = list.take(5).toList();
        },
      );

      results[1].fold(
        (f) => _handleFailure(f),
        (products) => activeProducts.value = (products as List).length,
      );

      results[2].fold(
        (f) => _handleFailure(f),
        (enquiries) {
          final list = enquiries as List;
          pendingEnquiries.value = list.where((e) => e.status.toString().contains('open')).length;
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _handleFailure(Failure failure) {
    errorMessage.value = failure.message;
  }

  Future<void> refresh() async => await loadDashboard();
}
