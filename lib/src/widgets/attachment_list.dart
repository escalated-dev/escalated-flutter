import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/attachment.dart';
import '../theme/colors.dart';

class AttachmentList extends StatelessWidget {
  final List<Attachment> attachments;
  final void Function(Attachment)? onDownload;

  const AttachmentList({
    super.key,
    required this.attachments,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            l10n.t('attachments'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        ...attachments.map((attachment) => _AttachmentTile(
              attachment: attachment,
              onDownload: onDownload,
            )),
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final Attachment attachment;
  final void Function(Attachment)? onDownload;

  const _AttachmentTile({
    required this.attachment,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.grey.withOpacity(0.06),
        borderRadius: AppRadius.baseBorder,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _fileIcon(attachment),
            size: 20,
            color: _fileIconColor(attachment),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.filename,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.formattedSize,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          if (onDownload != null)
            IconButton(
              icon: const Icon(Icons.download, size: 20),
              onPressed: () => onDownload!(attachment),
              tooltip: l10n.t('download'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
      ),
    );
  }

  IconData _fileIcon(Attachment attachment) {
    if (attachment.isImage) return Icons.image;
    if (attachment.isPdf) return Icons.picture_as_pdf;
    if (attachment.isDocument) return Icons.description;
    if (attachment.isSpreadsheet) return Icons.table_chart;
    if (attachment.isArchive) return Icons.archive;
    return Icons.insert_drive_file;
  }

  Color _fileIconColor(Attachment attachment) {
    if (attachment.isImage) return const Color(0xFF8B5CF6);
    if (attachment.isPdf) return const Color(0xFFEF4444);
    if (attachment.isDocument) return const Color(0xFF3B82F6);
    if (attachment.isSpreadsheet) return const Color(0xFF10B981);
    if (attachment.isArchive) return const Color(0xFFF59E0B);
    return const Color(0xFF6B7280);
  }
}
