import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/enquiry_entity.dart';
import '../../controllers/enquiry_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_states.dart';

class EnquiryPage extends StatelessWidget {
  const EnquiryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnquiryController>();
    return AppScaffold(
      title: AppStrings.myEnquiries,
      currentRoute: AppRoutes.enquiry,
      body: Obx(() {
        if (controller.isLoading.value && controller.enquiries.isEmpty) {
          return const AppLoadingView();
        }
        if (controller.errorMessage.value != null && controller.enquiries.isEmpty) {
          return AppErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
          );
        }
        if (controller.enquiries.isEmpty) {
          return AppEmptyView(
            title: AppStrings.noEnquiriesFound,
            message: 'Submit your first enquiry to get started',
            icon: Icons.help_outline,
            action: SizedBox(
              width: 200,
              child: AppButton(
                label: AppStrings.newEnquiry,
                onPressed: () => _showNewEnquiry(context, controller),
                icon: Icons.add,
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: Responsive.pagePadding(context),
            itemCount: controller.enquiries.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _EnquiryCard(enquiry: controller.enquiries[i]),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewEnquiry(context, controller),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.newEnquiry),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showNewEnquiry(BuildContext context, EnquiryController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewEnquirySheet(controller: controller),
    );
  }
}

class _NewEnquirySheet extends StatefulWidget {
  final EnquiryController controller;
  const _NewEnquirySheet({required this.controller});

  @override
  State<_NewEnquirySheet> createState() => _NewEnquirySheetState();
}

class _NewEnquirySheetState extends State<_NewEnquirySheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  EnquiryType _type = EnquiryType.general;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? AppStrings.requiredField : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await widget.controller.submitEnquiry(
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      type: _type,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, AppStrings.enquirySubmittedSuccess);
    } else {
      AppSnackBar.showError(context,
        widget.controller.errorMessage.value ?? AppStrings.somethingWentWrong);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(AppStrings.newEnquiry, style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              Text(AppStrings.enquiryType, style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: EnquiryType.values.map((t) => ChoiceChip(
                  label: Text(_typeLabel(t)),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: _type == t ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              AppInput(
                label: AppStrings.subject,
                hintText: 'Brief subject of your enquiry',
                controller: _subjectCtrl,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppInput(
                label: AppStrings.message,
                hintText: 'Describe your enquiry in detail',
                controller: _messageCtrl,
                validator: _required,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              Obx(() => AppButton(
                label: AppStrings.submitEnquiry,
                onPressed: _submit,
                isLoading: widget.controller.isSubmitting.value,
                icon: Icons.send,
              )),
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(EnquiryType t) {
    switch (t) {
      case EnquiryType.product: return AppStrings.productEnquiry;
      case EnquiryType.general: return AppStrings.generalEnquiry;
      case EnquiryType.price: return AppStrings.priceEnquiry;
      case EnquiryType.other: return 'Other';
    }
  }
}

class _EnquiryCard extends StatelessWidget {
  final EnquiryEntity enquiry;
  const _EnquiryCard({required this.enquiry});

  Color _statusColor() {
    switch (enquiry.status) {
      case EnquiryStatus.open: return AppColors.warning;
      case EnquiryStatus.inProgress: return AppColors.primary;
      case EnquiryStatus.resolved: return AppColors.success;
      case EnquiryStatus.closed: return AppColors.textHint;
    }
  }

  String _statusLabel() {
    switch (enquiry.status) {
      case EnquiryStatus.open: return AppStrings.open;
      case EnquiryStatus.inProgress: return 'In Progress';
      case EnquiryStatus.resolved: return AppStrings.resolved;
      case EnquiryStatus.closed: return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(enquiry.subject,
                  style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_statusLabel(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor())),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(enquiry.message,
            style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (enquiry.response != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(enquiry.response!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(DateFormat('dd MMM yyyy').format(enquiry.createdAt),
                style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}
