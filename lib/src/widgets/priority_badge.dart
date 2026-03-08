import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  final String? label;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.priorityColor(priority);
    final l10n = AppLocalizations.of(context);
    final displayLabel = label ?? l10n.t(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.badgeBorder,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _priorityIcon(priority),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            displayLabel,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.arrow_downward;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.arrow_upward;
      case 'urgent':
        return Icons.priority_high;
      case 'critical':
        return Icons.error;
      default:
        return Icons.remove;
    }
  }
}
