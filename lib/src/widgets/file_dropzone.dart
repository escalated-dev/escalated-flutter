import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';

class SelectedFile {
  final String name;
  final String path;
  final int size;

  const SelectedFile({
    required this.name,
    required this.path,
    required this.size,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class FileDropzone extends StatelessWidget {
  final List<SelectedFile> files;
  final ValueChanged<List<SelectedFile>> onFilesChanged;
  final int maxFiles;

  const FileDropzone({
    super.key,
    required this.files,
    required this.onFilesChanged,
    this.maxFiles = 10,
  });

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        final newFiles = result.files.where((f) => f.path != null).map((f) {
          return SelectedFile(
            name: f.name,
            path: f.path!,
            size: f.size,
          );
        }).toList();

        final combined = [...files, ...newFiles];
        if (combined.length > maxFiles) {
          onFilesChanged(combined.take(maxFiles).toList());
        } else {
          onFilesChanged(combined);
        }
      }
    } catch (_) {
      // Handle picker error silently
    }
  }

  void _removeFile(int index) {
    final updated = [...files];
    updated.removeAt(index);
    onFilesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.grey.withOpacity(0.04),
              borderRadius: AppRadius.baseBorder,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('drop_or_browse'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('browse_files'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...files.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const Icon(Icons.insert_drive_file, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.formattedSize,
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
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _removeFile(index),
                    tooltip: l10n.t('remove'),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
