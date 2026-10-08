import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/guest_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/reply_thread.dart';
import '../../widgets/sla_timer.dart';
import '../../widgets/status_badge.dart';
import 'guest_messages.dart';

/// A guest ticket, opened with the access grant stored for it.
///
/// [reference] is the ticket reference. Access grants are not part of the
/// route: they are kept per ticket by `GuestAccessStore`. When there is no
/// working grant (it ran out, was replaced, or the link is from before
/// verified access) the screen asks the guest to verify their email again.
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

  Future<void> _sendReply({required bool needsEmail}) async {
    final body = _replyController.text.trim();
    final email = _emailController.text.trim();
    if (body.isEmpty || (needsEmail && email.isEmpty)) return;

    final success = await ref
        .read(guestTicketProvider.notifier)
        .sendReply(
          reference: widget.reference,
          body: body,
          email: needsEmail ? email : null,
        );

    if (success && mounted) {
      _replyController.clear();
    }
  }

  // Share the reference, never the access grant: anyone holding the grant
  // could read the ticket until it runs out.
  void _copyReference(AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: widget.reference));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('reference_copied'))));
  }

  void _verifyAgain() {
    context.go(
      Uri(
        path: '/guest/lookup',
        queryParameters: {'reference': widget.reference},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(guestTicketProvider);
    final title = state.ticket?.reference ?? l10n.t('ticket');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(GuestTicketState state, AppLocalizations l10n) {
    if (state.needsVerification) {
      return _AccessRequired(onVerify: _verifyAgain);
    }

    if (state.isLoading && state.ticket == null) {
      return const ShimmerCard();
    }

    if (state.error != null && state.ticket == null) {
      return ErrorView(
        message: _errorText(state, l10n),
        onRetry: () =>
            ref.read(guestTicketProvider.notifier).loadTicket(widget.reference),
      );
    }

    final ticket = state.ticket;
    if (ticket == null) return const ShimmerCard();

    final scheme = Theme.of(context).colorScheme;
    final expiresAt = state.grant?.expiresAt;
    final grantEmail = state.grant?.email;
    final needsEmail = grantEmail == null || grantEmail.isEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Access notice: when it ends, and how to get back in.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.statusOpen.withValues(alpha: 0.08),
                    borderRadius: AppRadius.cardBorder,
                    border: Border.all(
                      color: AppColors.statusOpen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_clock_outlined,
                        color: AppColors.statusOpen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.tf('guest_access_expires', {
                            'date': expiresAt != null
                                ? AppLocalizations.formatDateTime(
                                    context,
                                    expiresAt,
                                  )
                                : '-',
                            'reference': ticket.reference,
                          }),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.statusOpen,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _copyReference(l10n),
                        icon: const Icon(Icons.copy, size: 16),
                        label: Text(l10n.t('copy_reference')),
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
                    color: scheme.surfaceContainerLow,
                    borderRadius: AppRadius.cardBorder,
                    border: Border.all(color: scheme.outlineVariant),
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
                        value: AppLocalizations.formatDateTime(
                          context,
                          ticket.createdAt,
                        ),
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
                      color: scheme.surfaceContainerLow,
                      borderRadius: AppRadius.cardBorder,
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      ticket.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: scheme.onSurface,
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
              color: scheme.surface,
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.error != null) ...[
                    Text(
                      _errorText(state, l10n),
                      style: TextStyle(color: scheme.error, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (needsEmail) ...[
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
                  ],
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
                      onPressed: state.isSendingReply
                          ? null
                          : () => _sendReply(needsEmail: needsEmail),
                      icon: state.isSendingReply
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
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

String _errorText(GuestTicketState state, AppLocalizations l10n) {
  final error = state.error ?? 'unexpected_error';
  if (error == 'guest_rate_limited' || error == 'guest_rate_limited_later') {
    return rateLimitText(l10n, state.retryAfter);
  }
  return l10n.t(error);
}

class _AccessRequired extends StatelessWidget {
  const _AccessRequired({required this.onVerify});

  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.t('guest_access_required'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const ValueKey('guest-verify-again'),
              onPressed: onVerify,
              child: Text(l10n.t('verify_email')),
            ),
          ],
        ),
      ),
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
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
