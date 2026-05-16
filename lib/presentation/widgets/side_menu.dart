import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../dependency_injection.dart';
import '../controllers/login_controller.dart';

class SideMenu extends StatelessWidget {
  final String currentRoute;
  const SideMenu({super.key, required this.currentRoute});

  // --- Exact Color Palette from Image ---
  final Color bgColor = const Color(0xFF113C36); // Main dark teal background
  final Color cardBg = const Color(0xFF09312B); // Profile card background
  final Color iconBg = const Color(0xFF1C4942); // Background behind icons
  final Color activeBg = const Color(0xFF19534A); // Active menu item background
  final Color accentCyan = const Color(0xFF60E0CE); // Cyan for text and dots
  final Color textMuted = const Color(0xFF6E8D88); // Muted grey/green text
  final Color dangerCoral = const Color(0xFFF27B7B); // Sign out text/icon

  @override
  Widget build(BuildContext context) {
    final effectiveRoute =
        currentRoute.trim().isEmpty ? AppRoutes.products : currentRoute;
    return Drawer(
      backgroundColor: bgColor,
      width: MediaQuery.of(context).size.width * 0.85, // Typical width for this design
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            _buildProfileCard(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _SectionHeader(title: 'BROWSE'),
                  _MenuItem(
                    icon: Icons.grid_view_rounded,
                    label: AppStrings.products, // Default
                    route: AppRoutes.products,
                    currentRoute: effectiveRoute,
                    onTap: () => _navigate(context, AppRoutes.products),
                  ),
                  _MenuItem(
                    icon: Icons.bar_chart,
                    label: AppStrings.dashboard,
                    route: AppRoutes.dashboard,
                    currentRoute: effectiveRoute,
                    onTap: () => _navigate(context, AppRoutes.dashboard),
                  ),
                  _MenuItem(
                    icon: Icons.explore_outlined,
                    label: AppStrings.findDistributor, // or 'Find distributor'
                    route: AppRoutes.findDistributor,
                    currentRoute: effectiveRoute,
                    onTap: () => _navigate(context, AppRoutes.findDistributor),
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'ACTIVITY'),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    label: AppStrings.orders, // or 'Orders'
                    route: AppRoutes.orders,
                    currentRoute: effectiveRoute,
                    onTap: () => _navigate(context, AppRoutes.orders),
                  ),
                  _MenuItem(
                    icon: Icons.mail_outline,
                    label: AppStrings.enquiry, // or 'Enquiries'
                    route: AppRoutes.enquiry,
                    currentRoute: effectiveRoute,
                    onTap: () => _navigate(context, AppRoutes.enquiry),
                  ),
                  _MenuItem(
                    icon: Icons.shopping_cart_outlined,
                    label: AppStrings.cart,
                    route: AppRoutes.cart,
                    currentRoute: effectiveRoute,
                    onTap: () => _navigate(context, AppRoutes.cart),
                  ),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    if (currentRoute != route) context.push(route);
  }

  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                'assets/images/virchow_rx_logo.svg',
                height: 34,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
          const SizedBox(width: 36), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final LoginController? loginController =
        Get.isRegistered<LoginController>() ? Get.find<LoginController>() : null;
    final user = loginController?.currentUser.value;
    final name = (user?.username ?? 'City Pharmacy').trim();
    final code = (user?.pharmacyCode ?? 'PH001').trim();
    final initials = name.isNotEmpty
        ? name.split(RegExp(r'\s+')).take(2).map((s) => s.isNotEmpty ? s[0] : '').join()
        : 'CP';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: accentCyan,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0B3B36),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E), // Online green dot
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBg, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  code,
                  style: TextStyle(color: textMuted, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF113C36),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _navigate(context, AppRoutes.changePassword),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: textMuted, size: 20),
                const SizedBox(width: 8),
                Text('Change Password', style: TextStyle(color: textMuted, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              DependencyInjection.bindLogin();
              await Get.find<LoginController>().logout();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.logout, color: dangerCoral, size: 20),
                const SizedBox(width: 8),
                Text('Sign out', style: TextStyle(color: dangerCoral, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF6E8D88),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute.startsWith(route);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF19534A) : Colors.transparent, // Active BG
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.transparent : const Color(0xFF1C4942),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF60E0CE) : Colors.white70,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: isActive ? const Icon(Icons.circle, color: Color(0xFF60E0CE), size: 10) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        dense: true,
      ),
    );
  }
}