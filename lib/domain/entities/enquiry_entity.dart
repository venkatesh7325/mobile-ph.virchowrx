import 'package:equatable/equatable.dart';

enum EnquiryStatus { open, inProgress, resolved, closed }
enum EnquiryType { product, general, price, other }

class EnquiryEntity extends Equatable {
  final String id;
  final String subject;
  final String message;
  final EnquiryType type;
  final EnquiryStatus status;
  final DateTime createdAt;
  final String? response;
  final String? productId;
  final String? productName;

  const EnquiryEntity({
    required this.id,
    required this.subject,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
    this.response,
    this.productId,
    this.productName,
  });

  @override
  List<Object?> get props => [id, subject, status, type];
}
