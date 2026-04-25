import '../../core/network/api_client.dart';
import '../models/enquiry_model.dart';

abstract class EnquiryRemoteDataSource {
  Future<List<EnquiryModel>> getEnquiries({int page = 1, int limit = 20});
  Future<EnquiryModel> getEnquiryById(String id);
  Future<EnquiryModel> submitEnquiry(Map<String, dynamic> data);
}

class EnquiryRemoteDataSourceImpl implements EnquiryRemoteDataSource {
  final ApiClient apiClient;
  const EnquiryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EnquiryModel>> getEnquiries({int page = 1, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return EnquiryModel.sampleList;
  }

  @override
  Future<EnquiryModel> getEnquiryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return EnquiryModel.sampleList.firstWhere((e) => e.id == id);
  }

  @override
  Future<EnquiryModel> submitEnquiry(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return EnquiryModel.sampleList.first;
  }
}
