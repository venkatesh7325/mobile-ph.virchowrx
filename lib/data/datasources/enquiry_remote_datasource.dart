import '../../core/errors/exceptions.dart';
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
    final response = await apiClient.get('/enquiries') as Map<String, dynamic>;
    final raw = response['enquiries'];
    if (raw is! List) return [];
    return raw.map((e) => EnquiryModel.fromPharmacy(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<EnquiryModel> getEnquiryById(String id) async {
    final list = await getEnquiries();
    return list.firstWhere(
      (e) => e.id == id,
      orElse: () => throw const NotFoundException(message: 'Enquiry not found'),
    );
  }

  @override
  Future<EnquiryModel> submitEnquiry(Map<String, dynamic> data) async {
    final distributorId = _asInt(data['distributor_id']);
    final productId = _asInt(data['product_id']);
    if (distributorId == null || productId == null) {
      throw const ValidationException(
        message: 'distributor_id and product_id are required for enquiries',
      );
    }

    final subject = data['subject']?.toString() ?? '';
    final message = data['message']?.toString() ?? '';
    final description = [subject, message].where((s) => s.isNotEmpty).join('\n');

    final response = await apiClient.post(
      '/enquiries',
      body: {
        'distributor_id': distributorId,
        'product_id': productId,
        'description': description.isEmpty ? message : description,
      },
    ) as Map<String, dynamic>;

    final enquiry = response['enquiry'] as Map<String, dynamic>?;
    if (enquiry != null) {
      return EnquiryModel.fromPharmacy(enquiry);
    }
    // Some backends return the enquiry at root
    if (response['id'] != null) {
      return EnquiryModel.fromPharmacy(response);
    }
    throw const ParseException(message: 'Unexpected enquiry create response');
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
