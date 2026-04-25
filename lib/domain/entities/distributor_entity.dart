import 'package:equatable/equatable.dart';

class DistributorEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String phone;
  final String? email;
  final double rating;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final bool isOpen;

  const DistributorEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.phone,
    this.email,
    required this.rating,
    this.latitude,
    this.longitude,
    this.distanceKm,
    this.isOpen = true,
  });

  @override
  List<Object?> get props => [id, name, city, state];
}
