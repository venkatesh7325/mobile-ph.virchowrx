import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/enquiry_entity.dart';

abstract class EnquiryRepository {
  Future<Either<Failure, List<EnquiryEntity>>> getEnquiries({
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<Either<Failure, EnquiryEntity>> getEnquiryById(String id);
  Future<Either<Failure, EnquiryEntity>> submitEnquiry(Map<String, dynamic> data);
  Future<Either<Failure, EnquiryEntity>> acceptEnquiryReply(int enquiryId);
}
