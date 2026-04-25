import 'package:get/get.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository repository;
  OrderController({required this.repository});

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final orders = <OrderEntity>[].obs;
  final selectedStatus = Rxn<OrderStatus>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.getOrders();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        orders.clear();
      },
      (data) => orders.value = data,
    );

    isLoading.value = false;
  }

  List<OrderEntity> get filteredOrders {
    if (selectedStatus.value == null) return orders;
    return orders.where((o) => o.status == selectedStatus.value).toList();
  }

  void setStatusFilter(OrderStatus? status) => selectedStatus.value = status;

  Future<void> refresh() async => await loadOrders();
}
