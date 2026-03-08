import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
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
      children: replies.map((reply) => _ReplyCard(
            reply: reply,
            onAttachmentDownload: onAttachmentDownload,
          )).toList(),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final Reply reply;
  final void Function(Reply)? onAttachmentDownload;

  const _ReplyCard({
    required this.reply,
    this.onAttachmentDownload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y · h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  reply.author.name.isNotEmpty
                      ? reply.author.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
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
                      dateFormat.format(reply.createdAt.toLocal()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (reply.isPinned)
                Icon(
                  Icons.push_pin,
                  size: 16,
                  color: AppColors.primary,
                ),
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
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              'p': Style(
                margin: Margins.only(bottom: 8),
              ),
              'a': Style(
                color: AppColors.primary,
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
