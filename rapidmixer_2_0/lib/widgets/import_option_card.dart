import 'package:flutter/material.dart';
import '../core/app_export.dart';

class ImportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const ImportOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.colorScheme.surface,
          border: Border.all(
            color: AppTheme.borderColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomIconWidget(
              icon: icon,
              size: 32,
              color: iconColor ?? AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: iconColor ?? AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.darkTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}