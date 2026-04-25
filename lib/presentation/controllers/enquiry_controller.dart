import 'package:get/get.dart';
import '../../domain/entities/enquiry_entity.dart';
import '../../domain/repositories/enquiry_repository.dart';

class EnquiryController extends GetxController {
  final EnquiryRepository repository;
  EnquiryController({required this.repository});

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final enquiries = <EnquiryEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadEnquiries();
  }

  Future<void> loadEnquiries() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await repository.getEnquiries();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        enquiries.clear();
      },
      (data) => enquiries.value = data,
    );

    isLoading.value = false;
  }

  Future<bool> submitEnquiry({
    required String subject,
    required String message,
    required EnquiryType type,
    String? productId,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = null;

    final result = await repository.submitEnquiry({
      'subject': subject,
      'message': message,
      'type': type.toString().split('.').last,
      if (productId != null) 'product_id': productId,
    });

    isSubmitting.value = false;
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        return false;
      },
      (_) {
        loadEnquiries();
        return true;
      },
    );
  }

  Future<void> refresh() async => await loadEnquiries();
}
