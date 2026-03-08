import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/reply_thread.dart';
import '../../widgets/sla_timer.dart';
import '../../widgets/status_badge.dart';

class GuestTicketScreen extends ConsumerStatefulWidget {
  final String reference;

  const GuestTicketScreen({super.key, required this.reference});

  @override
  ConsumerState<GuestTicketScreen> createState() => _GuestTicketScreenState();
}

class _GuestTicketScreenState extends ConsumerState<GuestTicketScreen> {
  final _replyController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(guestTicketProvider.notifier).loadTicket(widget.reference);
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final body = _replyController.text.trim();
    final email = _emailController.text.trim();
    if (body.isEmpty || email.isEmpty) return;

    final success = await ref.read(guestTicketProvider.notifier).sendReply(
          reference: widget.reference,
          body: body,
          email: email,
        );

    if (success && mounted) {
      _replyController.clear();
    }
  }

  void _copyLink() {
    final link = 'escalated://guest/${widget.reference}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(guestTicketProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reference),
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(TicketDetailState state, AppLocalizations l10n) {
    if (state.isLoading && state.ticket == null) {
      return const ShimmerCard();
    }

    if (state.error != null && state.ticket == null) {
      return ErrorView(
        message: state.error,
        onRetry: () => ref
            .read(guestTicketProvider.notifier)
            .loadTicket(widget.reference),
      );
    }

    final ticket = state.ticket;
    if (ticket == null) return const ShimmerCard();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y · h:mm a');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bookmark notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusOpen.withOpacity(0.08),
                    borderRadius: AppRadius.cardBorder,
                    border: Border.all(
                        color: AppColors.statusOpen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bookmark_outline,
                          color: AppColors.statusOpen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.t('bookmark_notice'),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.statusOpen,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _copyLink,
                        icon: const Icon(Icons.copy, size: 16),
                        label: Text(l10n.t('copy_link')),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.statusOpen,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subject
                Text(
                  ticket.subject,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Status and Priority badges
                Row(
                  children: [
                    StatusBadge(
                      status: ticket.status.value,
                      label: ticket.status.label,
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(
                      priority: ticket.priority.value,
                      label: ticket.priority.label,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Meta
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.grey.withOpacity(0.04),
                    borderRadius: AppRadius.cardBorder,
                    border: Border.all(
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      _MetaRow(
                        icon: Icons.tag,
                        label: l10n.t('reference'),
                        value: ticket.reference,
                      ),
                      if (ticket.department != null)
                        _MetaRow(
                          icon: Icons.business,
                          label: l10n.t('department'),
                          value: ticket.department!.name,
                        ),
                      _MetaRow(
                        icon: Icons.schedule,
                        label: l10n.t('created'),
                        value: dateFormat.format(ticket.createdAt.toLocal()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // SLA timers
                if (ticket.sla != null) ...[
                  Row(
                    children: [
                      SlaTimer(
                        dueAt: ticket.sla!.firstResponseDueAt,
                        breached: ticket.sla!.firstResponseBreached,
                        label: l10n.t('first_response'),
                      ),
                      const SizedBox(width: 8),
                      SlaTimer(
                        dueAt: ticket.sla!.resolutionDueAt,
                        breached: ticket.sla!.resolutionBreached,
                        label: l10n.t('resolution'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Description
                if (ticket.description.isNotEmpty) ...[
                  Text(
                    l10n.t('description'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.grey.withOpacity(0.04),
                      borderRadius: AppRadius.cardBorder,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      ticket.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Replies
                if (ticket.replies.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${l10n.t('reply')} (${ticket.replies.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ReplyThread(replies: ticket.replies),
                ],
              ],
            ),
          ),
        ),

        // Guest reply composer
        if (!ticket.isClosed)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: l10n.t('your_email'),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _replyController,
                    maxLines: 3,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: l10n.t('write_reply'),
                      border: const OutlineInputBorder(),
                    ),
                    enabled: !state.isSendingReply,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: state.isSendingReply ? null : _sendReply,
                      icon: state.isSendingReply
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
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
