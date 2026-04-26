import 'package:flutter/material.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  final TextEditingController _descController = TextEditingController(
    text:
    "Hi, I'd like to confirm availability of 25 units for next week's batch. Also, do you offer any volume pricing for orders above ₹10,000?",
  );
  String _selectedDistributor = 'CityMed Wholesale';
  String _selectedProduct = 'Jusgo · 75mg/mL Inj';

  static const Color primaryGreen = Color(0xFF0F6E56);
  static const Color accentGreen = Color(0xFF1D9E75);
  static const Color bgColor = Color(0xFFF4FAF7);

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
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
          _buildSendTag(),
          const SizedBox(height: 6),
          _buildHeading(),
          const SizedBox(height: 6),
          const Text(
            'Connect directly with our distributors. Average response time 12 minutes.',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888), height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildLabel('Distributor', required: true),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedDistributor,
            icon: Icons.grid_view_rounded,
            items: ['CityMed Wholesale', 'MedPlus Distribution', 'Sahayadri Pharma'],
            onChanged: (v) => setState(() => _selectedDistributor = v!),
          ),
          const SizedBox(height: 16),
          _buildLabel('Product', required: true),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _selectedProduct,
            icon: Icons.link,
            items: ['Jusgo · 75mg/mL Inj', 'Ranivox · INJ', 'Cefovix · INJ'],
            onChanged: (v) => setState(() => _selectedProduct = v!),
          ),
          const SizedBox(height: 16),
          _buildLabel('Description', required: true),
          const SizedBox(height: 8),
          _buildDescriptionField(),
          const SizedBox(height: 16),
          _buildSubmitBtn(),
        ],
      ),
    );
  }

  Widget _buildSendTag() {
    return Row(
      children: [
        Container(width: 20, height: 2, color: accentGreen),
        const SizedBox(width: 8),
        const Text(
          'SEND A REQUEST',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: Color(0xFF1D9E75)),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 28, color: Color(0xFF0F2D22), height: 1.15),
        children: [
          TextSpan(text: 'New ', style: TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(
            text: 'enquiry',
            style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w400, color: Color(0xFF1D9E75)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
        if (required)
          const Text(' *', style: TextStyle(fontSize: 13, color: Color(0xFF1D9E75), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E8E4), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF888888), size: 20),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A), fontFamily: 'default'),
          items: items
              .map((item) => DropdownMenuItem(
            value: item,
            child: Row(
              children: [
                Icon(icon, size: 15, color: const Color(0xFF888888)),
                const SizedBox(width: 10),
                Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A))),
              ],
            ),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E8E4), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _descController,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.attach_file, size: 13, color: Color(0xFF666666)),
                      SizedBox(width: 5),
                      Text('Attach file', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                    ],
                  ),
                ),
              ),
              Text(
                '${_descController.text.length} / 500',
                style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBtn() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Submit enquiry',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
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