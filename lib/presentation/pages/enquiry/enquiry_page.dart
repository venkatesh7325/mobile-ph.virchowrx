import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_client.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final TextEditingController _descController = TextEditingController();
  int? _selectedDistributorId;
  int? _selectedProductId;
  final List<_Option> _distributors = <_Option>[];
  final List<_Option> _products = <_Option>[];
  bool _loadingDistributors = false;
  bool _loadingProducts = false;
  bool _submitting = false;
  String? _loadError;
  String? _submitError;
  String? _submitSuccess;

  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color bgColor = Color(0xFFF4FAF7);

  bool get _isFormValid =>
      _selectedDistributorId != null &&
      _selectedProductId != null &&
      _descController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadDistributors();
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadDistributors() async {
    setState(() {
      _loadingDistributors = true;
      _loadError = null;
    });
    try {
      final api = Get.find<ApiClient>();
      final response = await api.get('/products/distributors') as Map<String, dynamic>;
      final raw = response['distributors'];
      if (raw is! List) {
        throw Exception('Unexpected distributors response');
      }
      final list = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map((m) {
            final id = (m['id'] as num?)?.toInt() ?? int.tryParse('${m['id']}') ?? 0;
            final name = (m['name'] ?? '').toString();
            return _Option(id: id, label: name.isEmpty ? 'Distributor #$id' : name);
          })
          .where((o) => o.id > 0)
          .toList();
      setState(() {
        _distributors
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      setState(() => _loadError = 'Failed to load distributors. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingDistributors = false);
    }
  }

  Future<void> _loadProductsForDistributor(int distributorId) async {
    setState(() {
      _loadingProducts = true;
      _loadError = null;
      _products.clear();
      _selectedProductId = null;
    });
    try {
      final api = Get.find<ApiClient>();
      final response = await api.get('/products/distributor/$distributorId') as Map<String, dynamic>;
      final raw = response['products'];
      if (raw is! List) {
        throw Exception('Unexpected products response');
      }
      final list = <_Option>[];
      for (final e in raw) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final product = m['product'] is Map ? Map<String, dynamic>.from(m['product'] as Map) : const <String, dynamic>{};
        final pid = (product['id'] as num?)?.toInt() ?? int.tryParse('${product['id']}') ?? 0;
        if (pid <= 0) continue;
        final name = (product['name'] ?? '').toString().trim();
        final sku = (product['sku'] ?? product['code'] ?? '').toString().trim();
        final label = sku.isNotEmpty ? '$name ($sku)' : (name.isNotEmpty ? name : 'Product #$pid');
        list.add(_Option(id: pid, label: label));
      }
      setState(() {
        _products
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      setState(() => _loadError = 'Failed to load products. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitError = null;
      _submitSuccess = null;
    });
    if (!_isFormValid) {
      setState(() => _submitError = 'Please fill all required fields.');
      return;
    }
    final distributorId = _selectedDistributorId!;
    final productId = _selectedProductId!;
    final description = _descController.text.trim();

    setState(() => _submitting = true);
    try {
      final api = Get.find<ApiClient>();
      await api.post(
        '/enquiries',
        body: {
          'distributor_id': distributorId,
          'product_id': productId,
          'description': description,
        },
      );
      if (!mounted) return;
      setState(() {
        _submitSuccess = 'Your enquiry has been submitted successfully.';
        _descController.clear();
        _selectedDistributorId = null;
        _selectedProductId = null;
        _products.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitError = 'Failed to submit enquiry. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildTopNav(context),
                    const SizedBox(height: 20),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildRecentEnquiries(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.chevron_left, onTap: () => Navigator.pop(context)),
        const Text(
          'Enquiry',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        _iconBtn(Icons.more_horiz),
      ],
    );
  }

  Widget _iconBtn(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: primaryGreen),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create an enquiry to a distributor about a specific product.',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
          ),
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            Text(
              _loadError!,
              style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
            ),
          ],
          if (_submitError != null) ...[
            const SizedBox(height: 12),
            Text(
              _submitError!,
              style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
            ),
          ],
          if (_submitSuccess != null) ...[
            const SizedBox(height: 12),
            Text(
              _submitSuccess!,
              style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 18),
          _buildDropdownFieldInt(
            label: 'Distributor *',
            value: _selectedDistributorId,
            items: _distributors,
            isLoading: _loadingDistributors,
            enabled: !_loadingDistributors && !_submitting,
            onChanged: (v) {
              setState(() => _selectedDistributorId = v);
              if (v != null) {
                _loadProductsForDistributor(v);
              } else {
                setState(() {
                  _products.clear();
                  _selectedProductId = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownFieldInt(
            label: 'Product *',
            value: _selectedProductId,
            items: _products,
            isLoading: _loadingProducts,
            enabled: _selectedDistributorId != null && !_loadingProducts && !_submitting,
            onChanged: (v) => setState(() => _selectedProductId = v),
          ),
          const SizedBox(height: 16),
          _buildDescriptionFieldWebLike(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: (_isFormValid && !_submitting) ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: const Color(0xFFE5E7EB),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text(
                  _submitting ? 'SUBMITTING...' : 'SUBMIT ENQUIRY',
                  style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFieldInt({
    required String label,
    required int? value,
    required List<_Option> items,
    required ValueChanged<int?> onChanged,
    bool enabled = true,
    bool isLoading = false,
  }) {
    final displayItems = items;
    return DropdownButtonFormField<int>(
      value: value,
      items: displayItems
          .map((o) => DropdownMenuItem<int>(value: o.id, child: Text(o.label)))
          .toList(),
      onChanged: enabled ? onChanged : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.keyboard_arrow_down),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildDescriptionFieldWebLike() {
    return TextField(
      controller: _descController,
      minLines: 4,
      maxLines: 6,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Description *',
        alignLabelWithHint: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildRecentEnquiries() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent enquiries',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View all →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _recentEnquiryItem('Lyfetran 1000', 'Pending', const Color(0xFFF5A623)),
      ],
    );
  }

  Widget _recentEnquiryItem(String name, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: primaryGreen,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 22),
    );
  }
}

class _Option {
  final int id;
  final String label;
  const _Option({required this.id, required this.label});
}