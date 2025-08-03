import 'package:flutter/material.dart';
import '../core/app_export.dart';

class SampleTrackCard extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  final VoidCallback onTap;
  final VoidCallback? onPlay;
  final bool isPlaying;

  const SampleTrackCard({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    required this.onTap,
    this.onPlay,
    this.isPlaying = false,
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                icon: Icons.music_note,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$artist • $duration',
                    style: AppTheme.darkTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (onPlay != null)
              IconButton(
                onPressed: onPlay,
                icon: CustomIconWidget(
                  icon: isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppTheme.accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}