import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/reply_composer.dart';
import '../../widgets/reply_thread.dart';
import '../../widgets/satisfaction_rating.dart';
import '../../widgets/sla_timer.dart';
import '../../widgets/status_badge.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  final String reference;

  const TicketDetailScreen({super.key, required this.reference});

  @override
  ConsumerState<TicketDetailScreen> createState() =>
      _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ticketDetailProvider.notifier).loadTicket(widget.reference);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(ticketDetailProvider);

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
            .read(ticketDetailProvider.notifier)
            .loadTicket(widget.reference),
      );
    }

    final ticket = state.ticket;
    if (ticket == null) {
      return const ShimmerCard();
    }

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

                // Meta info
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
                        icon: Icons.person_outline,
                        label: l10n.t('requester'),
                        value: ticket.requester.name,
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

                // Close / Reopen buttons
                if (!ticket.isClosed) ...[
                  Row(
                    children: [
                      if (ticket.isResolved || ticket.isOpen)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.isUpdating
                                ? null
                                : () async {
                                    if (ticket.isClosed || ticket.isResolved) {
                                      await ref
                                          .read(ticketDetailProvider.notifier)
                                          .reopenTicket(widget.reference);
                                    } else {
                                      await ref
                                          .read(ticketDetailProvider.notifier)
                                          .closeTicket(widget.reference);
                                    }
                                  },
                            icon: Icon(
                              ticket.isResolved
                                  ? Icons.refresh
                                  : Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: Text(
                              ticket.isResolved
                                  ? l10n.t('reopen_ticket')
                                  : l10n.t('close_ticket'),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.isUpdating
                              ? null
                              : () async {
                                  await ref
                                      .read(ticketDetailProvider.notifier)
                                      .reopenTicket(widget.reference);
                                },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(l10n.t('reopen_ticket')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Satisfaction rating when resolved
                if (ticket.isResolved) ...[
                  SatisfactionRating(
                    onSubmit: (rating, comment) {
                      ref.read(ticketDetailProvider.notifier).rateTicket(
                            reference: widget.reference,
                            rating: rating,
                            comment: comment,
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Replies section
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
        // Reply composer
        if (!ticket.isClosed)
          ReplyComposer(
            isSending: state.isSendingReply,
            onSend: (body, attachmentPaths) async {
              await ref.read(ticketDetailProvider.notifier).sendReply(
                    reference: widget.reference,
                    body: body,
                    attachmentPaths:
                        attachmentPaths.isNotEmpty ? attachmentPaths : null,
                  );
            },
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
