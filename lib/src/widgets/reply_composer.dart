import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';
import 'file_dropzone.dart';

class ReplyComposer extends StatefulWidget {
  final Future<void> Function(String body, List<String> attachmentPaths)
      onSend;
  final bool isSending;

  const ReplyComposer({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  @override
  State<ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<ReplyComposer> {
  final _textController = TextEditingController();
  List<SelectedFile> _files = [];
  bool _showAttachments = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _textController.text.trim();
    if (body.isEmpty) return;

    final paths = _files.map((f) => f.path).toList();
    await widget.onSend(body, paths);

    _textController.clear();
    setState(() {
      _files = [];
      _showAttachments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              maxLines: 4,
              minLines: 2,
              decoration: InputDecoration(
                hintText: l10n.t('write_reply'),
                border: const OutlineInputBorder(),
              ),
              enabled: !widget.isSending,
            ),
            if (_showAttachments) ...[
              const SizedBox(height: 12),
              FileDropzone(
                files: _files,
                onFilesChanged: (files) => setState(() => _files = files),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: _showAttachments
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  onPressed: widget.isSending
                      ? null
                      : () =>
                          setState(() => _showAttachments = !_showAttachments),
                  tooltip: l10n.t('attachments'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: widget.isSending ? null : _send,
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(l10n.t('send_reply')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
