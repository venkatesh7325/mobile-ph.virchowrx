import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/distributor_entity.dart';
import '../../controllers/distributor_controller.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class FindDistributorPage extends StatelessWidget {
  const FindDistributorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DistributorController>();
    return AppScaffold(
      title: AppStrings.findDistributorTitle,
      currentRoute: AppRoutes.findDistributor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: AppSearchInput(
              hintText: AppStrings.searchDistributor,
              onChanged: controller.setSearchQuery,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.distributors.isEmpty) {
                return const AppLoadingView();
              }
              if (controller.errorMessage.value != null && controller.distributors.isEmpty) {
                return AppErrorView(
                  message: controller.errorMessage.value!,
                  onRetry: controller.refresh,
                );
              }
              if (controller.filteredDistributors.isEmpty) {
                return const AppEmptyView(
                  title: AppStrings.noDistributorsFound,
                  icon: Icons.location_off,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  padding: Responsive.pagePadding(context),
                  itemCount: controller.filteredDistributors.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DistributorCard(distributor: controller.filteredDistributors[i]),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DistributorCard extends StatelessWidget {
  final DistributorEntity distributor;
  const _DistributorCard({required this.distributor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.store, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(distributor.name, style: AppTypography.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('${distributor.rating}', style: AppTypography.bodySmall),
                        const SizedBox(width: 12),
                        if (distributor.distanceKm != null) ...[
                          const Icon(Icons.location_on, size: 14, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Text('${distributor.distanceKm} km',
                            style: AppTypography.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: distributor.isOpen ? AppColors.successLight : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  distributor.isOpen ? AppStrings.openNow : 'Closed',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: distributor.isOpen ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.location_on_outlined,
            text: '${distributor.address}, ${distributor.city}, ${distributor.state} - ${distributor.pincode}'),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.phone_outlined, text: distributor.phone),
          if (distributor.email != null) ...[
            const SizedBox(height: 6),
            _InfoRow(icon: Icons.email_outlined, text: distributor.email!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text(AppStrings.contactDistributor, style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map, size: 16),
                  label: const Text(AppStrings.viewOnMap, style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTypography.bodySmall)),
      ],
    );
  }
}
