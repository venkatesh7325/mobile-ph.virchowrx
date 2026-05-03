import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/distributor_model.dart';

abstract class DistributorRemoteDataSource {
  Future<List<DistributorModel>> getDistributors({
    String? search,
    double? latitude,
    double? longitude,
    int page = 1,
    int limit = 20,
  });
  Future<DistributorModel> getDistributorById(String id);
}

class DistributorRemoteDataSourceImpl implements DistributorRemoteDataSource {
  final ApiClient apiClient;
  const DistributorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DistributorModel>> getDistributors({
    String? search,
    double? latitude,
    double? longitude,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await apiClient.get('/products/distributors') as Map<String, dynamic>;
    final raw = response['distributors'];
    if (raw is! List) return [];

    var list = raw.map((e) => DistributorModel.fromPharmacy(e as Map<String, dynamic>)).toList();

    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      list = list.where((d) => d.name.toLowerCase().contains(q) || d.city.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  @override
  Future<DistributorModel> getDistributorById(String id) async {
    final list = await getDistributors();
    return list.firstWhere(
      (d) => d.id == id,
      orElse: () => throw const NotFoundException(message: 'Distributor not found'),
    );
  }
}
