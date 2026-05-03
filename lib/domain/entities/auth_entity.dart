import 'package:equatable/equatable.dart';

class PharmacyEntity extends Equatable {
  final int id;
  final String name;
  final String? licenseNumber;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String? contactPerson;

  const PharmacyEntity({
    required this.id,
    required this.name,
    this.licenseNumber,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.phone,
    this.email,
    this.gstNumber,
    this.contactPerson,
  });

  @override
  List<Object?> get props => [
    id, name, licenseNumber, address, city, state, pincode,
    phone, email, gstNumber, contactPerson,
  ];
}

class UserEntity extends Equatable {
  final int id;
  final String username;
  final String token;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? role;
  final PharmacyEntity? pharmacy;

  const UserEntity({
    required this.id,
    required this.username,
    required this.token,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.role,
    this.pharmacy,
  });

  String get fullName {
    final parts = [firstName, lastName].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? username : parts.join(' ');
  }

  @override
  List<Object?> get props =>
      [id, username, token, firstName, lastName, email, phone, role, pharmacy];
}