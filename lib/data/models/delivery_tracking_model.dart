import '../../domain/entities/delivery_tracking_entity.dart';

class DeliveryTrackingModel extends DeliveryTrackingEntity {
  const DeliveryTrackingModel({
    super.deliveryOtp,
    super.assignmentStatus,
    super.partnerFirstName,
    super.partnerLastName,
    super.partnerPhone,
    super.currentLocation,
    super.pharmacyLocation,
    super.locationHistory,
  });

  factory DeliveryTrackingModel.fromJson(Map<String, dynamic> json) {
    final assignment = _asMap(json['assignment']);
    final partner = _asMap(json['partner']);
    final pharmacy = _asMap(json['pharmacy']);
    final currentLocation = _asMap(json['current_location']);

    MapCoordinate? partnerLocation;
    if (currentLocation != null) {
      partnerLocation = _coordFromMap(currentLocation);
    } else if (partner != null) {
      partnerLocation = _coordFromMap(partner, latKey: 'current_latitude', lngKey: 'current_longitude');
    }

    final historyRaw = json['location_history'];
    final history = <MapCoordinate>[];
    if (historyRaw is List) {
      for (final item in historyRaw) {
        final coord = _coordFromMap(_asMap(item));
        if (coord != null) history.add(coord);
      }
    }

    return DeliveryTrackingModel(
      deliveryOtp: json['delivery_otp']?.toString(),
      assignmentStatus: assignment?['status']?.toString(),
      partnerFirstName: partner?['first_name']?.toString(),
      partnerLastName: partner?['last_name']?.toString(),
      partnerPhone: partner?['phone']?.toString(),
      currentLocation: partnerLocation,
      pharmacyLocation: _coordFromMap(pharmacy),
      locationHistory: history,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static MapCoordinate? _coordFromMap(
    Map<String, dynamic>? map, {
    String latKey = 'latitude',
    String lngKey = 'longitude',
  }) {
    if (map == null) return null;
    final lat = _toDouble(map[latKey]);
    final lng = _toDouble(map[lngKey]);
    if (lat == null || lng == null) return null;
    return MapCoordinate(latitude: lat, longitude: lng);
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
