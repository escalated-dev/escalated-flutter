import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/ticket_summary.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import 'ticket_filters_sheet.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ticketListProvider.notifier).loadTickets(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(ticketListProvider.notifier).loadMore();
    }
  }

  void _showFilters() {
    final state = ref.read(ticketListProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketFiltersSheet(
        currentSearch: state.searchQuery,
        currentStatus: state.statusFilter,
        currentPriority: state.priorityFilter,
        onApply: (search, status, priority) {
          ref.read(ticketListProvider.notifier).setFilters(
                search: search,
                status: status,
                priority: priority,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(ticketListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tickets),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: l10n.t('filter'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/tickets/create'),
        tooltip: l10n.t('create_ticket'),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(TicketListState state, AppLocalizations l10n) {
    if (state.isLoading && state.tickets.isEmpty) {
      return const LoadingShimmer();
    }

    if (state.error != null && state.tickets.isEmpty) {
      return ErrorView(
        message: state.error,
        onRetry: () =>
            ref.read(ticketListProvider.notifier).loadTickets(refresh: true),
      );
    }

    if (!state.isLoading && state.tickets.isEmpty) {
      return EmptyState(
        icon: Icons.confirmation_number_outlined,
        title: l10n.t('no_tickets'),
        action: ElevatedButton.icon(
          onPressed: () => context.go('/tickets/create'),
          icon: const Icon(Icons.add),
          label: Text(l10n.t('create_ticket')),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(ticketListProvider.notifier).loadTickets(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: state.tickets.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.tickets.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _TicketCard(ticket: state.tickets[index]);
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketSummary ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: AppRadius.cardBorder,
        onTap: () => context.go('/tickets/${ticket.reference}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ticket.reference,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (ticket.slaBreached)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.slaRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.slaRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 12, color: AppColors.slaRed),
                          const SizedBox(width: 3),
                          Text(
                            'SLA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slaRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.subject,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  StatusBadge(
                    status: ticket.status,
                    label: ticket.statusLabel,
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(
                    priority: ticket.priority,
                    label: ticket.priorityLabel,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormat.format(ticket.createdAt.toLocal())} ${timeFormat.format(ticket.createdAt.toLocal())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  if (ticket.department != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.business,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        ticket.department!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
