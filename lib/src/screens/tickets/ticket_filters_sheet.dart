import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';

class TicketFiltersSheet extends StatefulWidget {
  final String? currentSearch;
  final String? currentStatus;
  final String? currentPriority;
  final void Function(String? search, String? status, String? priority) onApply;

  const TicketFiltersSheet({
    super.key,
    this.currentSearch,
    this.currentStatus,
    this.currentPriority,
    required this.onApply,
  });

  @override
  State<TicketFiltersSheet> createState() => _TicketFiltersSheetState();
}

class _TicketFiltersSheetState extends State<TicketFiltersSheet> {
  late TextEditingController _searchController;
  String? _selectedStatus;
  String? _selectedPriority;

  static const _statuses = [
    'open',
    'in_progress',
    'waiting_on_customer',
    'waiting_on_agent',
    'escalated',
    'resolved',
    'closed',
    'reopened',
  ];

  static const _priorities = ['low', 'medium', 'high', 'urgent', 'critical'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentSearch);
    _selectedStatus = widget.currentStatus;
    _selectedPriority = widget.currentPriority;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.t('filter'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.t('search_tickets'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('status'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.t('all_statuses'),
                  isSelected: _selectedStatus == null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                ..._statuses.map((status) => _FilterChip(
                      label: l10n.t(status),
                      isSelected: _selectedStatus == status,
                      color: AppColors.statusColor(status),
                      onTap: () => setState(() => _selectedStatus = status),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.t('priority'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.t('all_priorities'),
                  isSelected: _selectedPriority == null,
                  onTap: () => setState(() => _selectedPriority = null),
                ),
                ..._priorities.map((priority) => _FilterChip(
                      label: l10n.t(priority),
                      isSelected: _selectedPriority == priority,
                      color: AppColors.priorityColor(priority),
                      onTap: () => setState(() => _selectedPriority = priority),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _selectedStatus = null;
                        _selectedPriority = null;
                      });
                    },
                    child: Text(l10n.t('cancel')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(
                        _searchController.text.trim().isEmpty
                            ? null
                            : _searchController.text.trim(),
                        _selectedStatus,
                        _selectedPriority,
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.t('filter')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: AppRadius.badgeBorder,
          border: Border.all(
            color: isSelected ? chipColor : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? chipColor : null,
          ),
        ),
      ),
    );
  }
}
