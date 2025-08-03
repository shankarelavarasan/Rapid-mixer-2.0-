import 'package:flutter/material.dart';
import '../core/app_export.dart';

class FormatInfoBanner extends StatelessWidget {
  const FormatInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            icon: Icons.info_outline,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Supported formats: MP3, WAV, FLAC, M4A',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}