import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_client.dart';
import '../../../domain/entities/enquiry_entity.dart';
import '../../../domain/repositories/enquiry_repository.dart';

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

  final TextEditingController _enquirySearchCtrl = TextEditingController();
  Timer? _enquirySearchDebounce;
  List<EnquiryEntity> _enquiries = [];
  bool _enquiriesLoading = false;
  String? _enquiriesError;
  final Set<int> _acceptingIds = {};

  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color bgColor = Color(0xFFF4FAF7);
  static const TextStyle _formFieldLabelStyle = TextStyle(fontWeight: FontWeight.w700);

  bool get _isFormValid =>
      _selectedDistributorId != null &&
      _selectedProductId != null &&
      _descController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadDistributors();
    _loadRecentEnquiries();
    _enquirySearchCtrl.addListener(_onEnquirySearchChanged);
  }

  @override
  void dispose() {
    _enquirySearchDebounce?.cancel();
    _enquirySearchCtrl.removeListener(_onEnquirySearchChanged);
    _enquirySearchCtrl.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onEnquirySearchChanged() {
    _enquirySearchDebounce?.cancel();
    _enquirySearchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) _loadRecentEnquiries();
    });
  }

  Future<void> _loadRecentEnquiries() async {
    setState(() {
      _enquiriesLoading = true;
      _enquiriesError = null;
    });
    final result = await Get.find<EnquiryRepository>().getEnquiries(
      search: _enquirySearchCtrl.text,
    );
    if (!mounted) return;
    result.fold(
      (f) {
        setState(() {
          _enquiries = [];
          _enquiriesError = f.message;
          _enquiriesLoading = false;
        });
      },
      (data) {
        setState(() {
          _enquiries = List<EnquiryEntity>.from(data);
          _enquiriesLoading = false;
        });
      },
    );
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
      await _loadRecentEnquiries();
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
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _iconBtn(Icons.chevron_left, onTap: () => Navigator.pop(context)),
        const Text(
          'Enquiry',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
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
          _buildSearchableProductField(),
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
        labelStyle: _formFieldLabelStyle,
        floatingLabelStyle: _formFieldLabelStyle,
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

  String? _labelForSelectedProduct() {
    final id = _selectedProductId;
    if (id == null) return null;
    for (final o in _products) {
      if (o.id == id) return o.label;
    }
    return null;
  }

  InputDecoration _fieldDecoration({
    required String label,
    Widget? suffix,
    bool enabled = true,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: _formFieldLabelStyle,
      floatingLabelStyle: _formFieldLabelStyle,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGreen, width: 1.6),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabled: enabled,
    );
  }

  Widget _buildSearchableProductField() {
    final enabled =
        _selectedDistributorId != null && !_loadingProducts && !_submitting;
    final selected = _labelForSelectedProduct();
    final hint = _loadingProducts
        ? 'Loading products…'
        : (_selectedDistributorId == null
            ? 'Select a distributor first'
            : 'Tap to search & select product');

    return InkWell(
      onTap: enabled
          ? () async {
              final id = await showModalBottomSheet<int>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => _ProductSearchSheet(
                  products: _products,
                  primaryColor: primaryGreen,
                ),
              );
              if (id != null && mounted) {
                setState(() => _selectedProductId = id);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: _fieldDecoration(
          label: 'Product *',
          enabled: enabled && (_selectedDistributorId == null || !_loadingProducts),
          suffix: _loadingProducts
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Icon(
                  Icons.search,
                  color: enabled ? primaryGreen : Colors.grey,
                ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected ?? hint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: selected != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ],
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
        labelStyle: _formFieldLabelStyle,
        floatingLabelStyle: _formFieldLabelStyle,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 520;
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Recent enquiries',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _enquirySearchCtrl,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Description, distributor or product',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryGreen, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                   // _exportButtonsRow(wrap: true),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Recent enquiries',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  SizedBox(
                    width: math.min(260, c.maxWidth * 0.38),
                    child: TextField(
                      controller: _enquirySearchCtrl,
                      decoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Description, distributor…',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryGreen, width: 1.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _exportButtonsRow(wrap: false),
                ],
              );
            },
          ),
          if (_enquiriesError != null) ...[
            const SizedBox(height: 12),
            Text(
              _enquiriesError!,
              style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 14),
          if (_enquiriesLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_enquiries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No enquiries found yet.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            )
          else
            SizedBox(
              height: 400,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 8, bottom: 4),
                  itemCount: _enquiries.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final screenW = MediaQuery.sizeOf(context).width;
                    final cardW = math.min(320.0, math.max(260.0, screenW * 0.78));
                    return SizedBox(
                      width: cardW,
                      height: 400,
                      child: SingleChildScrollView(
                        child: _buildEnquiryCard(_enquiries[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  static const TextStyle _cardLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Color(0xFF4B5563),
    letterSpacing: 0.3,
  );
  static const TextStyle _cardValueStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF111827),
    height: 1.35,
  );

  Widget _buildEnquiryCard(EnquiryEntity e) {
    final df = DateFormat('dd/MM/yyyy');
    final tf = DateFormat('HH:mm');
    final productLine = _productLine(e);
    final replyPrice = e.replyPrice != null ? e.replyPrice!.toStringAsFixed(2) : '—';
    final replyDesc = (e.response ?? '').trim().isEmpty ? '—' : e.response!.trim();
    final hasReply = e.replyAt != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    df.format(e.createdAt.toLocal()),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                  ),
                  const Spacer(),
                  if (!hasReply)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Not replied',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                      ),
                    )
                  else if (e.replyAccepted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Accepted',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Reply received',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _cardField('Distributor', e.distributorName ?? '—'),
              _cardField('Product', productLine, maxLines: 3),
              _cardField('Description', e.message.trim().isEmpty ? '—' : e.message.trim(), maxLines: 5),
              const Divider(height: 22),
              _cardField('Reply price', replyPrice, maxLines: 1),
              _cardField('Reply description', replyDesc, maxLines: 4),
              const SizedBox(height: 8),
              _buildReplyInfoSection(e, df, tf),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardField(String label, String value, {int maxLines = 8}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: _cardLabelStyle),
          const SizedBox(height: 4),
          Text(
            value,
            style: _cardValueStyle,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _productLine(EnquiryEntity e) {
    final name = e.productName ?? e.subject;
    final sku = e.productSku?.trim();
    if (sku != null && sku.isNotEmpty) return '$name ($sku)';
    return name;
  }

  Widget _buildReplyInfoSection(EnquiryEntity e, DateFormat df, DateFormat tf) {
    final replyAt = e.replyAt;
    if (replyAt == null) {
      return const SizedBox.shrink();
    }
    final id = int.tryParse(e.id) ?? 0;
    final accepting = id > 0 && _acceptingIds.contains(id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REPLY INFO', style: _cardLabelStyle),
        const SizedBox(height: 6),
        Text(
          '${df.format(replyAt.toLocal())} · ${tf.format(replyAt.toLocal())}',
          style: _cardValueStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        if ((e.replyUserDisplay ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            e.replyUserDisplay!.trim(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
        if (e.replyAccepted && e.replyAcceptedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Accepted on ${df.format(e.replyAcceptedAt!.toLocal())} ${tf.format(e.replyAcceptedAt!.toLocal())}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontWeight: FontWeight.w600),
          ),
        ] else if (!e.replyAccepted) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: accepting || id <= 0 ? null : () => _confirmAcceptReply(id),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(accepting ? 'Accepting…' : 'ACCEPT REPLY', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmAcceptReply(int enquiryId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept reply?'),
        content: const Text('Accept this reply from the distributor?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _acceptingIds.add(enquiryId));
    final result = await Get.find<EnquiryRepository>().acceptEnquiryReply(enquiryId);
    if (!mounted) return;
    setState(() => _acceptingIds.remove(enquiryId));

    final messenger = ScaffoldMessenger.of(context);
    await result.fold<Future<void>>(
      (f) async {
        messenger.showSnackBar(SnackBar(content: Text(f.message)));
      },
      (_) async {
        messenger.showSnackBar(const SnackBar(content: Text('Reply accepted.')));
        await _loadRecentEnquiries();
      },
    );
  }

  Widget _exportButtonsRow({required bool wrap}) {
    final csvBtn = OutlinedButton(
      onPressed: _enquiries.isEmpty ? null : _exportCsv,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        side: const BorderSide(color: Color(0xFF2563EB)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: const Text('EXPORT EXCEL (CSV)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
    final pdfBtn = OutlinedButton(
      onPressed: _enquiries.isEmpty ? null : _exportPdf,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        side: const BorderSide(color: Color(0xFF2563EB)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      child: const Text('EXPORT PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
    if (wrap) {
      return Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.start, children: [csvBtn, pdfBtn]);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        csvBtn,
        const SizedBox(width: 8),
        pdfBtn,
      ],
    );
  }

  String _escapeCsvField(String? v) {
    final s = v ?? '';
    return '"${s.replaceAll('"', '""')}"';
  }

  Future<void> _exportCsv() async {
    final headers = [
      'Date',
      'Distributor',
      'Product',
      'Description',
      'Reply Price',
      'Reply Description',
      'Reply DateTime',
      'Reply User',
    ];
    final df = DateFormat('dd/MM/yyyy');
    final tf = DateFormat('HH:mm');
    final rows = _enquiries.map((e) {
      final replyLine = e.replyAt != null
          ? '${df.format(e.replyAt!.toLocal())} ${tf.format(e.replyAt!.toLocal())}'
          : '';
      return [
        df.format(e.createdAt.toLocal()),
        e.distributorName ?? '',
        _productLine(e),
        e.message,
        e.replyPrice != null ? e.replyPrice!.toStringAsFixed(2) : '',
        e.response ?? '',
        replyLine,
        e.replyUserDisplay ?? '',
      ];
    });
    final csv = [
      headers.join(','),
      ...rows.map((row) => row.map((f) => _escapeCsvField(f.toString())).join(',')),
    ].join('\n');

    try {
      final dir = await getTemporaryDirectory();
      final name = 'pharmacy-enquiries-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
      final file = File('${dir.path}/$name');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], subject: 'Pharmacy enquiries');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  String _escapeHtml(String s) {
    return s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  }

  Future<void> _exportPdf() async {
    final df = DateFormat('dd/MM/yyyy');
    final tf = DateFormat('HH:mm');
    final rowsHtml = _enquiries.map((e) {
      final replyLine = e.replyAt != null
          ? '${df.format(e.replyAt!.toLocal())} ${tf.format(e.replyAt!.toLocal())}'
          : '';
      return '<tr>'
          '<td>${_escapeHtml(df.format(e.createdAt.toLocal()))}</td>'
          '<td>${_escapeHtml(e.distributorName ?? '')}</td>'
          '<td>${_escapeHtml(_productLine(e))}</td>'
          '<td>${_escapeHtml(e.message)}</td>'
          '<td>${e.replyPrice != null ? e.replyPrice!.toStringAsFixed(2) : ''}</td>'
          '<td>${_escapeHtml(e.response ?? '')}</td>'
          '<td>${_escapeHtml(replyLine)}</td>'
          '<td>${_escapeHtml(e.replyUserDisplay ?? '')}</td>'
          '</tr>';
    }).join();

    final html = '''
<!DOCTYPE html>
<html><head><meta charset="utf-8"/><title>Pharmacy Enquiries</title>
<style>
body{font-family:system-ui,sans-serif;padding:16px;font-size:12px;}
table{width:100%;border-collapse:collapse;}
th,td{border:1px solid #ccc;padding:6px 8px;text-align:left;}
th{background:#f5f5f5;}
</style></head><body>
<h2>Pharmacy Enquiries</h2>
<table><thead><tr>
<th>Date</th><th>Distributor</th><th>Product</th><th>Enquiry</th>
<th>Reply Price</th><th>Reply Description</th><th>Reply DateTime</th><th>Reply User</th>
</tr></thead><tbody>$rowsHtml</tbody></table>
<script>window.onload=function(){window.print();}</script>
</body></html>''';

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/pharmacy-enquiries-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.html');
      await file.writeAsString(html);
      await Share.shareXFiles([XFile(file.path)], subject: 'Pharmacy enquiries (open and print to PDF)');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}

/// Bottom sheet: search field + filtered list; pops with selected product id.
class _ProductSearchSheet extends StatefulWidget {
  final List<_Option> products;
  final Color primaryColor;

  const _ProductSearchSheet({
    required this.products,
    required this.primaryColor,
  });

  @override
  State<_ProductSearchSheet> createState() => _ProductSearchSheetState();
}

class _ProductSearchSheetState extends State<_ProductSearchSheet> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_Option> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.products;
    return widget.products
        .where((o) => o.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: maxH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Search product',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Type product name…',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.primaryColor, width: 1.6),
                  ),
                ),
              ),
            ),
            Expanded(
              child: widget.products.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'No products for this distributor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                        ),
                      ),
                    )
                  : filtered.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No matches. Try a different search.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, i) {
                            final o = filtered[i];
                            return ListTile(
                              title: Text(
                                o.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => Navigator.pop(context, o.id),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option {
  final int id;
  final String label;
  const _Option({required this.id, required this.label});
}