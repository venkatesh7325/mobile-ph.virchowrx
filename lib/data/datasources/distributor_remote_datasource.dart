import '../../core/network/api_client.dart';
import '../models/distributor_model.dart';

abstract class DistributorRemoteDataSource {
  Future<List<DistributorModel>> getDistributors({
    String? search, double? latitude, double? longitude, int page = 1, int limit = 20,
  });
  Future<DistributorModel> getDistributorById(String id);
}

class DistributorRemoteDataSourceImpl implements DistributorRemoteDataSource {
  final ApiClient apiClient;
  const DistributorRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DistributorModel>> getDistributors({
    String? search, double? latitude, double? longitude, int page = 1, int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return DistributorModel.sampleList;
  }

  @override
  Future<DistributorModel> getDistributorById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DistributorModel.sampleList.firstWhere((d) => d.id == id);
  }
}
