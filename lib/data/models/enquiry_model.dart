import '../../domain/entities/enquiry_entity.dart';

class EnquiryModel extends EnquiryEntity {
  const EnquiryModel({
    required super.id,
    required super.subject,
    required super.message,
    required super.type,
    required super.status,
    required super.createdAt,
    super.response,
    super.productId,
    super.productName,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) => EnquiryModel(
        id: json['id']?.toString() ?? '',
        subject: json['subject'] ?? '',
        message: json['message'] ?? '',
        type: _parseType(json['type']),
        status: _parseStatus(json['status']),
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        response: json['response'],
        productId: json['product_id']?.toString(),
        productName: json['product_name'],
      );

  factory EnquiryModel.fromPharmacy(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final reply = json['reply_description']?.toString();
    return EnquiryModel(
      id: json['id']?.toString() ?? '',
      subject: product?['name']?.toString() ?? 'Enquiry',
      message: json['description']?.toString() ?? '',
      type: EnquiryType.product,
      status: _parseStatus(json['status']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      response: reply,
      productId: json['product_id']?.toString(),
      productName: product?['name']?.toString(),
    );
  }

  static EnquiryType _parseType(dynamic t) {
    switch (t?.toString().toLowerCase()) {
      case 'product':
        return EnquiryType.product;
      case 'price':
        return EnquiryType.price;
      case 'general':
        return EnquiryType.general;
      default:
        return EnquiryType.other;
    }
  }

  static EnquiryStatus _parseStatus(dynamic s) {
    switch (s?.toString().toLowerCase()) {
      case 'in_progress':
      case 'in progress':
        return EnquiryStatus.inProgress;
      case 'resolved':
      case 'accepted':
        return EnquiryStatus.resolved;
      case 'closed':
        return EnquiryStatus.closed;
      case 'open':
      case 'pending':
      default:
        return EnquiryStatus.open;
    }
  }

  static List<EnquiryModel> get sampleList => [
        EnquiryModel(
          id: '1',
          subject: 'Price inquiry for Widget A',
          message: 'Please provide bulk pricing for 100 units of Premium Widget A.',
          type: EnquiryType.price,
          status: EnquiryStatus.resolved,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          response: 'We offer 15% discount for orders above 50 units.',
          productId: '1',
          productName: 'Premium Widget A',
        ),
        EnquiryModel(
          id: '2',
          subject: 'Stock availability query',
          message: 'When will Safety Gloves Pro be back in stock?',
          type: EnquiryType.product,
          status: EnquiryStatus.inProgress,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          productId: '3',
          productName: 'Safety Gloves Pro',
        ),
        EnquiryModel(
          id: '3',
          subject: 'General inquiry about distribution',
          message: 'I want to become a distributor for your products in Pune.',
          type: EnquiryType.general,
          status: EnquiryStatus.open,
          createdAt: DateTime.now(),
        ),
      ];
}
