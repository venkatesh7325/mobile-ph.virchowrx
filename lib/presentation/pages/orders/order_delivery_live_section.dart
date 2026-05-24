import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/maps_config.dart';
import '../../../domain/entities/delivery_tracking_entity.dart';
import '../../../domain/repositories/order_repository.dart';
import 'live_delivery_otp_section.dart';

/// Loads `GET /orders/:id/delivery-tracking` and renders web-style live delivery UI.
class OrderDeliveryLiveSection extends StatefulWidget {
  final String orderId;
  final bool showMap;

  const OrderDeliveryLiveSection({
    super.key,
    required this.orderId,
    this.showMap = true,
  });

  @override
  State<OrderDeliveryLiveSection> createState() => _OrderDeliveryLiveSectionState();
}

class _OrderDeliveryLiveSectionState extends State<OrderDeliveryLiveSection> {
  Timer? _refreshTimer;
  DeliveryTrackingEntity? _tracking;
  bool _loading = true;
  String? _error;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _loadTracking();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) => _loadTracking(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTracking({bool silent = false}) async {
    if (!mounted) return;
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final result = await Get.find<OrderRepository>().getDeliveryTracking(widget.orderId);
    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
        if (!silent) _tracking = null;
      }),
      (data) => setState(() {
        _loading = false;
        _error = null;
        _tracking = data;
      }),
    );
  }

  LatLng _resolveMapCenter(DeliveryTrackingEntity tracking) {
    final partner = tracking.mapPartnerLocation;
    if (partner != null) {
      return LatLng(partner.latitude, partner.longitude);
    }
    final pharmacy = tracking.pharmacyLocation;
    if (pharmacy != null) {
      return LatLng(pharmacy.latitude, pharmacy.longitude);
    }
    return const LatLng(kDefaultMapLat, kDefaultMapLng);
  }

  Set<Marker> _buildMarkers(DeliveryTrackingEntity tracking) {
    final markers = <Marker>{};
    final partner = tracking.mapPartnerLocation;
    if (partner != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('partner'),
          position: LatLng(partner.latitude, partner.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
    final pharmacy = tracking.pharmacyLocation;
    if (pharmacy != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('pharmacy'),
          position: LatLng(pharmacy.latitude, pharmacy.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _tracking == null) {
      return LiveDeliveryOtpSection(
        driverLabel: 'Delivery partner',
        deliveryStatus: 'in transit',
        isLoadingOtp: true,
        mapChild: widget.showMap ? _buildMapPlaceholder() : null,
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB8D4F0), width: 1.2),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live delivery & OTP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(fontSize: 12, height: 1.4, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final tracking = _tracking;
    if (tracking == null) return const SizedBox.shrink();

    final mapCenter = _resolveMapCenter(tracking);
    final markers = _buildMarkers(tracking);
    final hasMapData = markers.isNotEmpty;

    return LiveDeliveryOtpSection(
      driverLabel: tracking.partnerDisplayName,
      deliveryStatus: tracking.assignmentStatusDisplay,
      otp: tracking.showOtp ? tracking.deliveryOtp : null,
      isLoadingOtp: false,
      mapChild: widget.showMap
          ? (hasMapData
              ? _DeliveryTrackingMap(
                  mapCenter: mapCenter,
                  markers: markers,
                  mapReady: _mapReady,
                  onMapCreated: (_) => setState(() => _mapReady = true),
                )
              : _buildMapUnavailable())
          : null,
    );
  }

  Widget _buildMapPlaceholder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: ColoredBox(
          color: const Color(0xFFE8EEF4),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 10),
                Text(
                  'Loading driver location…',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapUnavailable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: ColoredBox(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Location not available yet. Tracking updates when the partner is en route.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryTrackingMap extends StatelessWidget {
  final LatLng mapCenter;
  final Set<Marker> markers;
  final bool mapReady;
  final void Function(GoogleMapController) onMapCreated;

  const _DeliveryTrackingMap({
    required this.mapCenter,
    required this.markers,
    required this.mapReady,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: mapCenter, zoom: 14),
                  markers: markers,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  onMapCreated: onMapCreated,
                ),
                if (!mapReady)
                  const ColoredBox(
                    color: Color(0xFFE8EEF4),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Map updates every 15 seconds while this window is open.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ),
      ],
    );
  }
}

bool isDeliveryTrackableStatus(String status) {
  switch (status.toLowerCase()) {
    case 'billed':
    case 'shipped':
    case 'processing':
    case 'approved':
      return true;
    default:
      return false;
  }
}
