import 'package:get/get.dart';
import '../../domain/entities/distributor_entity.dart';
import '../../domain/repositories/distributor_repository.dart';

class DistributorController extends GetxController {
  final DistributorRepository repository;
  DistributorController({required this.repository});

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final distributors = <DistributorEntity>[].obs;
  final filteredDistributors = <DistributorEntity>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDistributors();
  }

  Future<void> loadDistributors() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.getDistributors();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        distributors.clear();
        filteredDistributors.clear();
      },
      (data) {
        distributors.value = data;
        filteredDistributors.value = data;
      },
    );

    isLoading.value = false;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredDistributors.value = distributors;
    } else {
      final q = query.toLowerCase();
      filteredDistributors.value = distributors
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.city.toLowerCase().contains(q) ||
              d.address.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<void> refresh() async => await loadDistributors();
}
