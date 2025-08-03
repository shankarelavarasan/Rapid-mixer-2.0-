import 'package:flutter/material.dart';
import '../core/app_export.dart';

class RecentFileItem extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String lastModified;
  final VoidCallback onTap;

  const RecentFileItem({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.lastModified,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CustomIconWidget(
          icon: Icons.audio_file,
          color: AppTheme.accentColor,
        ),
      ),
      title: Text(
        fileName,
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$fileSize • $lastModified',
        style: AppTheme.darkTheme.textTheme.bodySmall,
      ),
      trailing: const CustomIconWidget(
        icon: Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
    );
  }
}