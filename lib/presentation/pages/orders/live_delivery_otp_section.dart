import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'order_ui_model.dart';

/// Web-style "Live delivery & OTP" block: driver, status badge, cream OTP card.
class LiveDeliveryOtpSection extends StatelessWidget {
  final String driverLabel;
  final String deliveryStatus;
  final String? otp;
  final Widget? mapChild;
  final bool showCopyButton;
  final bool isLoadingOtp;
  final bool alwaysShowOtpCard;

  const LiveDeliveryOtpSection({
    super.key,
    required this.driverLabel,
    required this.deliveryStatus,
    this.otp,
    this.mapChild,
    this.showCopyButton = true,
    this.isLoadingOtp = false,
    this.alwaysShowOtpCard = true,
  });

  factory LiveDeliveryOtpSection.fromOrder(
    OrderModel order, {
    String? otpOverride,
    Widget? mapChild,
    bool showCopyButton = true,
    bool isLoadingOtp = false,
  }) {
    return LiveDeliveryOtpSection(
      driverLabel: order.driverDisplayLabel,
      deliveryStatus: order.deliveryStatusDisplay,
      otp: otpOverride ?? order.deliveryOtp,
      mapChild: mapChild,
      showCopyButton: showCopyButton,
      isLoadingOtp: isLoadingOtp,
    );
  }

  static List<String> otpDigits(String raw) {
    return raw.replaceAll(RegExp(r'\s'), '').split('');
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = otp?.trim();
    final hasOtp = trimmed != null && trimmed.isNotEmpty;

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
          const SizedBox(height: 10),
          Text(
            'Driver: $driverLabel',
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: orderBlueAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              deliveryStatus,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (alwaysShowOtpCard) ...[
            const SizedBox(height: 14),
            if (hasOtp)
              WebStyleOtpCard(
                otp: trimmed,
                showCopyButton: showCopyButton,
              )
            else
              _OtpPlaceholderCard(isLoading: isLoadingOtp),
          ],
          if (mapChild != null) ...[
            const SizedBox(height: 14),
            mapChild!,
          ],
        ],
      ),
    );
  }
}

class _OtpPlaceholderCard extends StatelessWidget {
  final bool isLoading;

  const _OtpPlaceholderCard({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFE65100)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Give this code to the delivery partner when they arrive:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF5D4037), height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4E342E)),
            )
          else
            const Text(
              'OTP not available yet',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
        ],
      ),
    );
  }
}

class WebStyleOtpCard extends StatelessWidget {
  final String otp;
  final bool showCopyButton;
  final bool compact;

  const WebStyleOtpCard({
    super.key,
    required this.otp,
    this.showCopyButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final digits = LiveDeliveryOtpSection.otpDigits(otp.trim());
    final codeStyle = TextStyle(
      fontSize: compact ? 26 : 32,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF4E342E),
      letterSpacing: compact ? 8 : 10,
      height: 1.1,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: compact ? 16 : 18,
                color: const Color(0xFFE65100),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Give this code to the delivery partner when they arrive:',
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    color: const Color(0xFF5D4037),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 12 : 16),
          Center(
            child: Text(digits.join(' '), style: codeStyle),
          ),
          if (showCopyButton) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: otp.trim()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delivery OTP copied')),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18, color: orderPrimaryGreen),
                label: const Text(
                  'Copy OTP',
                  style: TextStyle(fontWeight: FontWeight.w700, color: orderPrimaryGreen),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
