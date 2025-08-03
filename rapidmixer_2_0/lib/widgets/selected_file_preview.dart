import 'package:flutter/material.dart';
import '../core/app_export.dart';

class SelectedFilePreview extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String duration;
  final VoidCallback onRemove;
  final VoidCallback? onPlay;
  final bool isPlaying;

  const SelectedFilePreview({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.duration,
    required this.onRemove,
    this.onPlay,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const CustomIconWidget(
              icon: Icons.audio_file,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileSize • $duration',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onPlay != null)
            IconButton(
              onPressed: onPlay,
              icon: CustomIconWidget(
                icon: isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppTheme.successColor,
              ),
            ),
          IconButton(
            onPressed: onRemove,
            icon: const CustomIconWidget(
              icon: Icons.close,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}