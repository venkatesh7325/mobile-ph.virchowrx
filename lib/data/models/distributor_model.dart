import '../../domain/entities/distributor_entity.dart';

class DistributorModel extends DistributorEntity {
  const DistributorModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.state,
    required super.pincode,
    required super.phone,
    super.email,
    required super.rating,
    super.latitude,
    super.longitude,
    super.distanceKm,
    super.isOpen,
  });

  factory DistributorModel.fromJson(Map<String, dynamic> json) => DistributorModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        state: json['state'] ?? '',
        pincode: json['pincode'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'],
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        isOpen: json['is_open'] ?? true,
      );

  static List<DistributorModel> get sampleList => const [
        DistributorModel(
          id: '1', name: 'Sharma Distributors', address: '45, MG Road',
          city: 'Hyderabad', state: 'Telangana', pincode: '500001',
          phone: '+91 98765 43210', email: 'sharma@dist.com', rating: 4.5,
          latitude: 17.3850, longitude: 78.4867, distanceKm: 2.3, isOpen: true,
        ),
        DistributorModel(
          id: '2', name: 'Krishna Traders', address: '12, Banjara Hills',
          city: 'Hyderabad', state: 'Telangana', pincode: '500034',
          phone: '+91 87654 32109', rating: 4.2,
          latitude: 17.4123, longitude: 78.4500, distanceKm: 5.1, isOpen: true,
        ),
        DistributorModel(
          id: '3', name: 'Reddy & Sons', address: '78, Secunderabad',
          city: 'Secunderabad', state: 'Telangana', pincode: '500015',
          phone: '+91 76543 21098', rating: 3.8,
          latitude: 17.4399, longitude: 78.4983, distanceKm: 8.7, isOpen: false,
        ),
      ];
}
