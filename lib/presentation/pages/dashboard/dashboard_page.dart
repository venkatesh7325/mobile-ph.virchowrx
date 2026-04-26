import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/order_entity.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return AppScaffold(
      title: AppStrings.dashboard,
      currentRoute: AppRoutes.dashboard,
      body: Obx(() {
        if (controller.isLoading.value && controller.recentOrders.isEmpty) {
          return const AppLoadingView();
        }
        if (controller.errorMessage.value != null && controller.recentOrders.isEmpty) {
          return AppErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildHeader(),
                // const SizedBox(height: 24),
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildActiveOrderValueCard(),
                const SizedBox(height: 16),
                _buildStatusGrid(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {

            },
            icon: const Icon(Icons.menu, color: AppColors.primaryTeal),
          ),
          Text(
            'VIRCHOW Rx',
            style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryTeal),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.grey),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: AppColors.badgeUrgent, shape: BoxShape.circle),
                  child: const Text('10',
                      style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildWelcomeSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            Text(
              'City Pharmacy',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      'PH001',
                      style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('·   Mumbai · Maharashtra',
                      style: GoogleFonts.montserrat(
                          fontSize: 10, color: AppColors.textLight)),
                ],
              ),
            ),
          ],
        ),
        // --- The Fixed Circle ---
        Positioned(
          top: 0,
          right: -150,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gridIconBlue,
                  AppColors.primaryTeal,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryTeal.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            // Adding the SP Text in the center
            child: Center(
              child: Text(
                'SP',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveOrderValueCard() {
    return Stack(
      children: [
        // This container provides the background and fixed height
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF168A7F), Color(0xFF0C9D91), Color(0xFF8CD8B8)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: CustomPaint(painter: WavePatternPainter()),
          ),
        ),
        // FIX: Wrap the foreground content in a SizedBox with the same height as the background
        // so the Spacer() has a boundary to expand into.
        SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ACTIVE ORDER VALUE',
                        style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2)),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 14, color: AppColors.accentGold),
                        const SizedBox(width: 4),
                        Text('+12.4%',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '₹1,24,500.00',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const Spacer(), // Now this won't crash because it's inside a 180px box
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildWeekCompareCol('THIS WEEK', '₹89,200'),
                        const SizedBox(width: 24),
                        _buildWeekCompareCol('LAST WEEK', '₹79,300'),
                      ],
                    ),
                    SizedBox(
                      width: 80,
                      height: 30,
                      child: CustomPaint(painter: SparklinePainter()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCompareCol(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.montserrat(fontSize: 9, color: Colors.white70)),
        Text(value,
            style: GoogleFonts.montserrat(
                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildStatusGrid(BuildContext context) {
    return GridView.count(
      // Keep these two properties to avoid "infinite height" errors
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildGridCard(AppColors.gridIconBlue, Icons.view_in_ar_outlined, '247',
            'Total orders', '+24', AppColors.primaryTeal),
        _buildGridCard(AppColors.gridIconGold, Icons.access_time_outlined, '3',
            'Pending', 'Urgent', AppColors.accentGold),
        _buildGridCard(AppColors.gridIconBlue, Icons.link, '1,420', 'In stock',
            'SKUs', AppColors.primaryTeal),
        _buildGridCard(AppColors.gridIconPurple, Icons.inbox_outlined, '8',
            'Distributors', null, const Color(0xFF6B7280)),
      ],
    );
  }

  Widget _buildGridCard(Color iconBg, IconData icon, String value, String title,
      String? badgeText, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.05))),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              Text(
                title,
                style: GoogleFonts.montserrat(
                    fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
          if (badgeText != null)
            Positioned(
              top: 0,
              right: 0,
              child: _buildBadge(badgeText, accentColor),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    bool isUrgent = text == 'Urgent';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: isUrgent ? AppColors.badgeUrgentBg : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: GoogleFonts.montserrat(
              color: isUrgent ? AppColors.badgeUrgent : color,
              fontSize: 9,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFab() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryTeal, AppColors.primaryTealDark],
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryTeal.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: const Icon(Icons.headphones_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}

class WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (double r = 50; r < size.width * 1.5; r += 40) {
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), r, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.6);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.3);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

