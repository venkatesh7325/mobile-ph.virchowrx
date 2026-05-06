import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transparent app bar with a white rounded back control and centered title,
/// matching [ProductsPage] / pharmacy register.
class SimpleBackAppBar {
  SimpleBackAppBar._();

  static const Color teal = Color(0xFF168A7F);
  static const Color titleColor = Color(0xFF111827);

  static PreferredSizeWidget build(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    String? fallbackRoute,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else if (fallbackRoute != null && fallbackRoute.isNotEmpty) {
              context.go(fallbackRoute);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: const Icon(Icons.chevron_left, color: teal),
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: titleColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: actions,
    );
  }
}
