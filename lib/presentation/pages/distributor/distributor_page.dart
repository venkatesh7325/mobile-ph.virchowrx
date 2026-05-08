import 'package:flutter/material.dart';

import 'distributer_details_screen.dart';
class DistributorsListScreen extends StatefulWidget {
  const DistributorsListScreen({super.key});

  @override
  State<DistributorsListScreen> createState() => _DistributorsListScreenState();
}

class _DistributorsListScreenState extends State<DistributorsListScreen> {
  final Color primaryGreen = const Color(0xFF0F6E56);
  final Color accentGreen = const Color(0xFF1D9E75);
  final Color bgColor = const Color(0xFFF4FAF7);

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedState = 'All';
  String _selectedCity = 'All';
  String _selectedPincode = 'All';

  final List<Map<String, dynamic>> distributors = [
    {
      'initials': 'CM',
      'name': 'CityMed Wholesale',
      'location': 'Baner, Pune',
      'state': 'Maharashtra',
      'city': 'Pune',
      'pincode': '411045',
      'distance': '4.2 km',
      'rating': 4.9,
      'products': 324,
      'active': true,
      'code': 'DIST002',
      'gst': '27BBBBB2345B1Z6',
      'avatarColor': Color(0xFF1D9E75),
      'avatarColor2': Color(0xFF0F6E56),
      'verified': true,
    },
    {
      'initials': 'MP',
      'name': 'MedPlus Distribution',
      'location': 'Hinjewadi, Pune',
      'state': 'Maharashtra',
      'city': 'Pune',
      'pincode': '411057',
      'distance': '6.8 km',
      'rating': 4.7,
      'products': 512,
      'active': true,
      'code': 'DIST005',
      'gst': '27CCCCC4567C1Z2',
      'avatarColor': Color(0xFF7F77DD),
      'avatarColor2': Color(0xFF534AB7),
      'verified': true,
    },
    {
      'initials': 'SP',
      'name': 'Sahayadri Pharma',
      'location': 'Kothrud, Pune',
      'state': 'Maharashtra',
      'city': 'Pune',
      'pincode': '411038',
      'distance': '9.1 km',
      'rating': 4.5,
      'products': 186,
      'active': false,
      'code': '',
      'gst': '',
      'avatarColor': Color(0xFFF5A623),
      'avatarColor2': Color(0xFFE67E22),
      'verified': false,
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDistributors {
    final q = _searchCtrl.text.trim().toLowerCase();
    return distributors.where((d) {
      final state = (d['state']?.toString() ?? '').trim();
      final city = (d['city']?.toString() ?? '').trim();
      final pin = (d['pincode']?.toString() ?? '').trim();

      if (_selectedState != 'All' && state.toLowerCase() != _selectedState.toLowerCase()) return false;
      if (_selectedCity != 'All' && city.toLowerCase() != _selectedCity.toLowerCase()) return false;
      if (_selectedPincode != 'All' && pin != _selectedPincode) return false;

      if (q.isEmpty) return true;
      final name = (d['name']?.toString() ?? '').toLowerCase();
      final code = (d['code']?.toString() ?? '').toLowerCase();
      final loc = (d['location']?.toString() ?? '').toLowerCase();
      return name.contains(q) || code.contains(q) || loc.contains(q) || city.toLowerCase().contains(q) || state.toLowerCase().contains(q) || pin.contains(q);
    }).toList();
  }

  List<String> get _states {
    final s = <String>{};
    for (final d in distributors) {
      final v = (d['state']?.toString() ?? '').trim();
      if (v.isNotEmpty) s.add(v);
    }
    final out = s.toList()..sort();
    return ['All', ...out];
  }

  List<String> get _cities {
    final s = <String>{};
    for (final d in distributors) {
      final v = (d['city']?.toString() ?? '').trim();
      if (v.isNotEmpty) s.add(v);
    }
    final out = s.toList()..sort();
    return ['All', ...out];
  }

  List<String> get _pincodes {
    final s = <String>{};
    for (final d in distributors) {
      final v = (d['pincode']?.toString() ?? '').trim();
      if (v.isNotEmpty) s.add(v);
    }
    final out = s.toList()..sort();
    return ['All', ...out];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredDistributors;
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildTopNav(context),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 12),
                        _buildFilterRow(),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildDistributorCard(
                        filtered[index],
                        context,
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(
              bottom: 28,
              right: 20,
              child: _buildFAB(),
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
        _navIconBtn(
          child: const Icon(Icons.chevron_left, size: 22, color: Color(0xFF1D9E75)),
          onTap: () => Navigator.pop(context),
        ),
        const Text(
          'Find Distributors',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        _cartBtn(),
      ],
    );
  }

  Widget _navIconBtn({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFE2F0EB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }

  Widget _cartBtn() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE2F0EB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.shopping_cart_outlined, size: 18, color: Color(0xFF1D9E75)),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFE74C3C),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF4FAF7), width: 2),
            ),
            child: const Center(
              child: Text('10', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, size: 16, color: Color(0xFFAAAAAA)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                  hintText: 'Search by name or code...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.white),
            ),
          ),
          if (_searchCtrl.text.trim().isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF888888)),
              onPressed: () {
                _searchCtrl.clear();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdown(
                value: _selectedState,
                items: _states,
                hint: 'State',
                onChanged: (v) => setState(() => _selectedState = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dropdown(
                value: _selectedCity,
                items: _cities,
                hint: 'City',
                onChanged: (v) => setState(() => _selectedCity = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dropdown(
                value: _selectedPincode,
                items: _pincodes,
                hint: 'Pincode',
                onChanged: (v) => setState(() => _selectedPincode = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() {
                    _selectedState = 'All';
                    _selectedCity = 'All';
                    _selectedPincode = 'All';
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryGreen,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: primaryGreen.withOpacity(0.35)),
                  ),
                ),
                child: const Text(
                  'CLEAR FILTERS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2F0EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : 'All',
          hint: Text(hint, overflow: TextOverflow.ellipsis),
          items: items
              .map(
                (s) => DropdownMenuItem<String>(
                  value: s,
                  child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildDistributorCard(Map<String, dynamic> dist, BuildContext context) {
    final bool active = dist['active'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(dist['initials'], dist['avatarColor'], dist['avatarColor2']),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              dist['name'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                            ),
                          ),
                          if (dist['verified'] == true) ...[
                            const SizedBox(width: 5),
                            _verifiedBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 11, color: Color(0xFF888888)),
                          const SizedBox(width: 2),
                          Text(
                            '${dist['location']} · ${dist['distance']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Color(0xFFF5A623)),
                          const SizedBox(width: 3),
                          Text(
                            '${dist['rating']}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(width: 6),
                          const Text('|', style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 11)),
                          const SizedBox(width: 6),
                          Text(
                            '${dist['products']} products',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                          ),
                          const SizedBox(width: 8),
                          if (active) _activeBadge() else _closedBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (active) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: const Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dist['code']} · GST ${dist['gst']}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA), letterSpacing: 0.2),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DistributorDetailScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F6E56),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Text('View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Text('→', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String initials, Color color1, Color color2) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _verifiedBadge() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle),
      child: const Icon(Icons.check, size: 9, color: Colors.white),
    );
  }

  Widget _activeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FAF3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF1D9E75), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF1D9E75))),
        ],
      ),
    );
  }

  Widget _closedBadge() {
    return const Text('Closed', style: TextStyle(fontSize: 11, color: Color(0xFF999999), fontWeight: FontWeight.w500));
  }

  Widget _buildFAB() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0F6E56),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color(0xFF0F6E56).withOpacity(0.45), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 22),
    );
  }
}