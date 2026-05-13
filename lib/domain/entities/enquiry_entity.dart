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
  /// Distributor display name from nested `distributor` on pharmacy enquiries API.
  final String? distributorName;
  final String? productSku;
  /// Parsed `reply_price` when distributor replied.
  final double? replyPrice;
  final DateTime? replyAt;
  final String? replyUserDisplay;
  final bool replyAccepted;
  final DateTime? replyAcceptedAt;

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
    this.distributorName,
    this.productSku,
    this.replyPrice,
    this.replyAt,
    this.replyUserDisplay,
    this.replyAccepted = false,
    this.replyAcceptedAt,
  });

  @override
  List<Object?> get props => [
        id,
        subject,
        status,
        type,
        distributorName,
        replyPrice,
        replyAccepted,
      ];
}
