class MapCoordinate {
  final double latitude;
  final double longitude;

  const MapCoordinate({required this.latitude, required this.longitude});
}

/// Live delivery payload from `GET /orders/:id/delivery-tracking` (matches web).
class DeliveryTrackingEntity {
  final String? deliveryOtp;
  final String? assignmentStatus;
  final String? partnerFirstName;
  final String? partnerLastName;
  final String? partnerPhone;
  final MapCoordinate? currentLocation;
  final MapCoordinate? pharmacyLocation;
  final List<MapCoordinate> locationHistory;

  const DeliveryTrackingEntity({
    this.deliveryOtp,
    this.assignmentStatus,
    this.partnerFirstName,
    this.partnerLastName,
    this.partnerPhone,
    this.currentLocation,
    this.pharmacyLocation,
    this.locationHistory = const [],
  });

  String get partnerDisplayName {
    final name = '${partnerFirstName ?? ''} ${partnerLastName ?? ''}'.trim();
    if (name.isNotEmpty) {
      if (partnerPhone != null && partnerPhone!.trim().isNotEmpty) {
        return '$name • ${partnerPhone!.trim()}';
      }
      return name;
    }
    return 'Delivery partner';
  }

  String get assignmentStatusDisplay {
    final raw = assignmentStatus?.trim();
    if (raw == null || raw.isEmpty) return 'in transit';
    return raw.replaceAll('_', ' ');
  }

  bool get showOtp {
    final otp = deliveryOtp?.trim();
    if (otp == null || otp.isEmpty) return false;
    return assignmentStatus?.toLowerCase() != 'delivered';
  }

  MapCoordinate? get mapPartnerLocation => currentLocation;
}
