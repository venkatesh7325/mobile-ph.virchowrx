import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/pharmacy_registration.dart';
import '../../controllers/register_controller.dart';
import '../../widgets/app_states.dart';
import '../../widgets/simple_back_app_bar.dart';

/// Indian states / UTs for pharmacy address (same set as web portal).
const _kIndianStates = <String>[
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Andaman and Nicobar Islands',
  'Chandigarh',
  'Dadra and Nagar Haveli and Daman and Diu',
  'Delhi',
  'Jammu and Kashmir',
  'Ladakh',
  'Lakshadweep',
  'Puducherry',
];

/// Maps form [name] keys to `/auth/check-unique` `field` values (web portal contract).
const _kUniqueApiByFormKey = <String, String>{
  'pharmacy_license_number': 'license_number',
  'pharmacy_name': 'pharmacy_name',
  'pharmacy_phone': 'pharmacy_phone',
  'pharmacy_email': 'pharmacy_email',
  'pharmacy_gst_number': 'gst_number',
  'pharmacy_pan_number': 'pan_number',
  'username': 'username',
  'email': 'user_email',
  'phone': 'user_phone',
};

const _kMaxUploadBytes = 5 * 1024 * 1024;

const _kBorder = Color(0xFFE0E0E0);
const _kTitle = Color(0xFF111111);
const _kMuted = Color(0xFF6B7280);
const _kFieldFill = Color(0xFFFAFAFA);
const _kTeal = Color(0xFF168A7F);

/// Pharmacy self-registration: multipart `POST /auth/register`, aligned with the web app.
class PharmacyRegisterPage extends StatefulWidget {
  const PharmacyRegisterPage({super.key});

  @override
  State<PharmacyRegisterPage> createState() => _PharmacyRegisterPageState();
}

class _PharmacyRegisterPageState extends State<PharmacyRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterController _controller;

  final _licenseCtrl = TextEditingController();
  final _pharmaNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _pharmaPhoneCtrl = TextEditingController();
  final _pharmaEmailCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _verificationCodeCtrl = TextEditingController();

  String? _state;
  bool _verificationSent = false;
  String? _devVerificationCode;

  final Map<String, String> _uniqueErrors = {};
  final Map<String, Timer> _debouncers = {};
  bool _fetchingLocation = false;

  String? _panPath;
  String? _gstPath;
  String? _licensePath;
  String? _panLabel;
  String? _gstLabel;
  String? _licenseLabel;
  final Map<String, String> _docErrors = {};

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RegisterController>();
  }

  @override
  void dispose() {
    for (final t in _debouncers.values) {
      t.cancel();
    }
    _licenseCtrl.dispose();
    _pharmaNameCtrl.dispose();
    _addressCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _pharmaPhoneCtrl.dispose();
    _pharmaEmailCtrl.dispose();
    _gstCtrl.dispose();
    _panCtrl.dispose();
    _contactCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _verificationCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    if (_fetchingLocation) return;
    setState(() => _fetchingLocation = true);
    try {
      // 1) Make sure Location Services are ON
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        AppSnackBar.showError(context, 'Please enable location services');
        return;
      }

      // 2) Check / Request permission on button click
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
        AppSnackBar.showError(context, 'Location permission denied');
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (_) {
        // Emulator sometimes fails to acquire a fresh fix; try last known.
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        AppSnackBar.showError(
          context,
          'Could not fetch location. Set a mock location in the emulator and try again.',
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _latitudeCtrl.text = pos!.latitude.toStringAsFixed(6);
        _longitudeCtrl.text = pos.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(context, 'Could not fetch location. Set a mock location in the emulator and try again.');
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  void _debounceUnique(String formKey, String value) {
    final apiField = _kUniqueApiByFormKey[formKey];
    if (apiField == null) return;
    _debouncers[formKey]?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _uniqueErrors.remove(formKey));
      return;
    }
    _debouncers[formKey] = Timer(const Duration(milliseconds: 800), () async {
      final r = await _controller.checkUnique(apiFieldName: apiField, value: value);
      if (!mounted) return;
      r.fold((_) {}, (u) {
        setState(() {
          if (!u.isUnique) {
            _uniqueErrors[formKey] = u.message;
          } else {
            _uniqueErrors.remove(formKey);
          }
        });
      });
    });
  }

  Future<void> _blurUnique(String formKey, String value) async {
    final apiField = _kUniqueApiByFormKey[formKey];
    if (apiField == null || value.trim().isEmpty) return;
    _debouncers[formKey]?.cancel();
    final r = await _controller.checkUnique(apiFieldName: apiField, value: value);
    if (!mounted) return;
    r.fold((_) {}, (u) {
      setState(() {
        if (!u.isUnique) {
          _uniqueErrors[formKey] = u.message;
        } else {
          _uniqueErrors.remove(formKey);
        }
      });
    });
  }

  Future<void> _sendVerification() async {
    FocusScope.of(context).unfocus();
    final email = _pharmaEmailCtrl.text.trim();
    final err = Validators.email(email);
    if (err != null) {
      AppSnackBar.showError(context, err);
      return;
    }
    final r = await _controller.sendVerification(email);
    if (!mounted) return;
    r.fold(
      (_) => AppSnackBar.showError(context, _controller.errorMessage.value ?? 'Could not send code'),
      (s) {
        setState(() {
          _verificationSent = true;
          _devVerificationCode = s.devCode;
        });
        final extra = (s.devCode != null && s.devCode!.isNotEmpty) ? ' Code: ${s.devCode}' : '';
        AppSnackBar.showSuccess(context, '${s.message}$extra');
      },
    );
  }

  Future<void> _pickDoc(String key) async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (r == null || r.files.isEmpty) return;
    final f = r.files.single;
    var len = f.size;
    final path = f.path;
    if (len <= 0 && path != null && path.isNotEmpty) {
      try {
        len = await File(path).length();
      } catch (_) {}
    }
    if (len > _kMaxUploadBytes) {
      setState(() => _docErrors[key] = 'File must be 5MB or smaller');
      return;
    }
    if (path == null || path.isEmpty) {
      AppSnackBar.showError(context, 'Could not read file path');
      return;
    }
    setState(() {
      _docErrors.remove(key);
      final name = f.name;
      if (key == 'pan') {
        _panPath = path;
        _panLabel = name;
      } else if (key == 'gst') {
        _gstPath = path;
        _gstLabel = name;
      } else {
        _licensePath = path;
        _licenseLabel = name;
      }
    });
  }

  InputDecoration _decoration(String label, {String? helper, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      filled: true,
      fillColor: _kFieldFill,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kTitle, width: 1.4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: _kMuted, fontWeight: FontWeight.w500),
    );
  }

  Widget _uniqueLine(String formKey) {
    final m = _uniqueErrors[formKey];
    if (m == null || m.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(m, style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }

  Widget _outlineField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? formKeyUnique,
    int? maxLength,
    String? helper,
    bool enabled = true,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          enabled: enabled,
          readOnly: readOnly,
          onChanged: formKeyUnique != null ? (v) => _debounceUnique(formKeyUnique, v) : null,
          onEditingComplete: formKeyUnique != null
              ? () => _blurUnique(formKeyUnique, controller.text)
              : null,
          decoration: _decoration(label, helper: helper),
          validator: validator,
        ),
        if (formKeyUnique != null) _uniqueLine(formKeyUnique),
      ],
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _controller.clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_verificationSent || _verificationCodeCtrl.text.trim().isEmpty) {
      AppSnackBar.showError(context, 'Please verify pharmacy email and enter the code');
      return;
    }

    final coordError = Validators.pharmacyCoordinates(
      _latitudeCtrl.text,
      _longitudeCtrl.text,
    );
    if (coordError != null) {
      AppSnackBar.showError(context, coordError);
      return;
    }

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      AppSnackBar.showError(context, 'Passwords do not match');
      return;
    }

    if (_panPath == null) {
      setState(() => _docErrors['pan'] = 'PAN document is required');
      AppSnackBar.showError(context, 'Please upload all required documents');
      return;
    }
    if (_gstPath == null) {
      setState(() => _docErrors['gst'] = 'GST document is required');
      AppSnackBar.showError(context, 'Please upload all required documents');
      return;
    }
    if (_licensePath == null) {
      setState(() => _docErrors['license'] = 'License document is required');
      AppSnackBar.showError(context, 'Please upload all required documents');
      return;
    }

    if (_uniqueErrors.values.any((e) => e.isNotEmpty)) {
      AppSnackBar.showError(context, 'Please fix duplicate-field errors before submitting');
      return;
    }

    final payload = PharmacyRegistrationPayload(
      pharmacyLicenseNumber: _licenseCtrl.text.trim(),
      pharmacyName: _pharmaNameCtrl.text.trim(),
      pharmacyAddress: _addressCtrl.text.trim(),
      pharmacyCity: _cityCtrl.text.trim(),
      pharmacyState: _state ?? '',
      pharmacyPincode: _pincodeCtrl.text.trim(),
      pharmacyPhone: _pharmaPhoneCtrl.text.trim(),
      pharmacyEmail: _pharmaEmailCtrl.text.trim(),
      pharmacyGstNumber: _gstCtrl.text.trim().toUpperCase(),
      pharmacyPanNumber: _panCtrl.text.trim().toUpperCase(),
      pharmacyContactPerson: _contactCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      emailVerificationCode: _verificationCodeCtrl.text.trim(),
      panDocumentPath: _panPath!,
      gstDocumentPath: _gstPath!,
      licenseDocumentPath: _licensePath!,
      pharmacyLatitude: _latitudeCtrl.text.trim(),
      pharmacyLongitude: _longitudeCtrl.text.trim(),
    );

    final r = await _controller.register(payload);
    if (!mounted) return;
    r.fold(
      (_) => AppSnackBar.showError(context, _controller.errorMessage.value ?? 'Registration failed'),
      (msg) async {
        AppSnackBar.showSuccess(context, msg);
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) context.go(AppRoutes.login);
      },
    );
  }

  Widget _docRow(String key, String title) {
    final err = _docErrors[key];
    String? label;
    if (key == 'pan') label = _panLabel;
    if (key == 'gst') label = _gstLabel;
    if (key == 'license') label = _licenseLabel;
    final hasFile = label != null && label.trim().isNotEmpty;
    final borderColor = err != null ? Colors.red.shade400 : _kBorder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _kTitle),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _pickDoc(key),
              borderRadius: BorderRadius.circular(10),
              splashColor: _kTeal.withOpacity(0.08),
              highlightColor: _kTeal.withOpacity(0.04),
              child: Ink(
                decoration: BoxDecoration(
                  color: _kFieldFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: err != null ? 1.5 : 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: hasFile ? _kTeal.withOpacity(0.12) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          hasFile ? Icons.insert_drive_file_rounded : Icons.upload_file_rounded,
                          color: hasFile ? _kTeal : _kMuted,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasFile ? label.trim() : 'No file selected',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: hasFile ? FontWeight.w600 : FontWeight.w500,
                                color: hasFile ? _kTitle : _kMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PDF, JPEG, JPG or PNG · up to 5 MB',
                              style: TextStyle(fontSize: 11, color: _kMuted, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasFile ? 'Replace' : 'Choose file',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _kTeal,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right_rounded, color: _kTeal, size: 22),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(err, style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _kTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: SimpleBackAppBar.build(
        context,
        title: 'Register',
        fallbackRoute: AppRoutes.login,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Obx(() {
              final e = _controller.errorMessage.value;
              if (e == null || e.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(e, style: TextStyle(color: Colors.red.shade800, fontSize: 13)),
                  ),
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pharmacy Registration',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _kTitle),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Register Your Pharmacy Account',
                    style: TextStyle(color: _kMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Pharmacy Information'),
                  _outlineField(
                    controller: _licenseCtrl,
                    label: 'License Number *',
                    validator: (v) => Validators.required(v, 'License number'),
                    formKeyUnique: 'pharmacy_license_number',
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _pharmaNameCtrl,
                    label: 'Pharmacy Name *',
                    validator: (v) => Validators.required(v, 'Pharmacy name'),
                    formKeyUnique: 'pharmacy_name',
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _addressCtrl,
                    label: 'Pharmacy Address *',
                    validator: (v) => Validators.required(v, 'Address'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _fetchingLocation ? null : _getLocation,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _kTeal.withOpacity(0.45)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _fetchingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: _kTeal),
                            )
                          : const Icon(Icons.my_location, color: _kTeal, size: 18),
                      label: Text(
                        _fetchingLocation ? 'Fetching...' : 'Get location',
                        style: const TextStyle(color: _kTeal, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Maps location — use Get location or enter latitude and longitude.',
                      style: TextStyle(fontSize: 12, color: _kMuted, height: 1.35),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: _outlineField(
                          controller: _latitudeCtrl,
                          label: 'Latitude *',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                          ],
                          validator: Validators.latitude,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _outlineField(
                          controller: _longitudeCtrl,
                          label: 'Longitude *',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                          ],
                          validator: Validators.longitude,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _cityCtrl,
                    label: 'City *',
                    validator: (v) => Validators.required(v, 'City'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _state,
                    isExpanded: true,
                    decoration: _decoration('State *'),
                    hint: const Text('Select state', overflow: TextOverflow.ellipsis),
                    items: _kIndianStates
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) => _kIndianStates
                        .map(
                          (s) => Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              s,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _state = v),
                    validator: (v) => (v == null || v.isEmpty) ? 'State is required' : null,
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _pincodeCtrl,
                    label: 'Pincode *',
                    validator: Validators.pincodeIndia,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _pharmaPhoneCtrl,
                    label: 'Pharmacy Phone *',
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    formKeyUnique: 'pharmacy_phone',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _pharmaEmailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (v) => _debounceUnique('pharmacy_email', v),
                              onEditingComplete: () => _blurUnique('pharmacy_email', _pharmaEmailCtrl.text),
                              decoration: _decoration('Pharmacy Email *'),
                              validator: Validators.email,
                            ),
                            _uniqueLine('pharmacy_email'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Obx(
                          () => OutlinedButton(
                            onPressed: _controller.sendingVerification.value ? null : _sendVerification,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _kMuted,
                              side: const BorderSide(color: _kBorder),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            child: _controller.sendingVerification.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('VERIFY\nEMAIL', textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_verificationSent) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _verificationCodeCtrl,
                      decoration: _decoration('Email verification code *'),
                      validator: (v) => Validators.required(v, 'Verification code'),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _gstCtrl,
                    label: 'GST Number *',
                    validator: Validators.gstNumber,
                    maxLength: 15,
                    formKeyUnique: 'pharmacy_gst_number',
                    helper: 'Must be exactly 15 characters',
                  ),
                  const Divider(height: 32),
                  _outlineField(
                    controller: _panCtrl,
                    label: 'PAN Number *',
                    validator: Validators.panNumber,
                    maxLength: 10,
                    formKeyUnique: 'pharmacy_pan_number',
                    helper: 'Must be exactly 10 characters',
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _contactCtrl,
                    label: 'Contact Person *',
                    validator: (v) => Validators.required(v, 'Contact person'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Required Documents (PDF, JPEG, JPG, or PNG — max 5MB each)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  _docRow('pan', 'PAN Document *'),
                  _docRow('gst', 'GST Document *'),
                  _docRow('license', 'License Document *'),
                  const Divider(height: 28),
                  _sectionTitle('User Account Information'),
                  _outlineField(
                    controller: _firstNameCtrl,
                    label: 'First Name *',
                    validator: (v) => Validators.required(v, 'First name'),
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _lastNameCtrl,
                    label: 'Last Name *',
                    validator: (v) => Validators.required(v, 'Last name'),
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _usernameCtrl,
                    label: 'Username *',
                    validator: Validators.usernameOrPharmacyCode,
                    formKeyUnique: 'username',
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _emailCtrl,
                    label: 'Email Address *',
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    formKeyUnique: 'email',
                  ),
                  const SizedBox(height: 14),
                  _outlineField(
                    controller: _phoneCtrl,
                    label: 'Phone Number *',
                    validator: Validators.phone,
                    keyboardType: TextInputType.phone,
                    formKeyUnique: 'phone',
                    helper: '10–15 digits',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: _decoration('Password *'),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: true,
                    decoration: _decoration('Confirm Password *'),
                    validator: (v) => Validators.confirmPassword(_passwordCtrl.text, v),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _controller.isLoading.value ? null : _submit,
                        style: ButtonStyle(
                          elevation: const WidgetStatePropertyAll(0),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) return const Color(0xFFE5E7EB);
                            return _kTeal;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) return const Color(0xFF4B5563);
                            return Colors.white;
                          }),
                        ),
                        child: _controller.isLoading.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('REGISTER PHARMACY', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                      ),
                    ),
                  ),
                  if (_devVerificationCode != null && _devVerificationCode!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Non-production hint: last sent code was $_devVerificationCode',
                        style: const TextStyle(fontSize: 11, color: _kMuted),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
