import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../l10n/app_localizations.dart';
import '../models/reply.dart';
import '../theme/colors.dart';
import 'attachment_list.dart';

class ReplyThread extends StatelessWidget {
  final List<Reply> replies;
  final void Function(Reply)? onAttachmentDownload;

  const ReplyThread({
    super.key,
    required this.replies,
    this.onAttachmentDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Column(
      children: replies
          .map(
            (reply) => _ReplyCard(
              reply: reply,
              onAttachmentDownload: onAttachmentDownload,
            ),
          )
          .toList(),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final Reply reply;
  final void Function(Reply)? onAttachmentDownload;

  const _ReplyCard({required this.reply, this.onAttachmentDownload});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                child: Text(
                  reply.author.name.isNotEmpty
                      ? reply.author.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.author.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      AppLocalizations.formatDateTime(context, reply.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (reply.isPinned)
                Icon(Icons.push_pin, size: 16, color: scheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          Html(
            data: reply.body,
            style: {
              'body': Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14),
                color: scheme.onSurface,
              ),
              'p': Style(margin: Margins.only(bottom: 8)),
              'a': Style(
                color: scheme.primary,
                textDecoration: TextDecoration.none,
              ),
            },
          ),
          if (reply.attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            AttachmentList(attachments: reply.attachments),
          ],
        ],
      ),
    );
  }
}
