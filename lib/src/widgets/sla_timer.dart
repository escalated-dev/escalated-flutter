import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';

class SlaTimer extends StatelessWidget {
  final String? dueAt;
  final bool breached;
  final String label;

  const SlaTimer({
    super.key,
    this.dueAt,
    this.breached = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (dueAt == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final dueDate = DateTime.tryParse(dueAt!);
    if (dueDate == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final difference = dueDate.difference(now);
    final isOverdue = difference.isNegative;

    Color color;
    if (isOverdue || breached) {
      color = AppColors.slaRed;
    } else if (difference.inHours < 2) {
      color = AppColors.slaYellow;
    } else {
      color = AppColors.slaGreen;
    }

    String timeText;
    if (isOverdue) {
      final overdueDuration = now.difference(dueDate);
      if (overdueDuration.inHours > 0) {
        timeText =
            '${l10n.t('overdue')} ${overdueDuration.inHours}${l10n.t('hours')[0]}';
      } else {
        timeText =
            '${l10n.t('overdue')} ${overdueDuration.inMinutes}${l10n.t('minutes')[0]}';
      }
    } else {
      if (difference.inHours > 0) {
        timeText =
            '${l10n.t('due_in')} ${difference.inHours} ${l10n.t('hours')}';
      } else {
        timeText =
            '${l10n.t('due_in')} ${difference.inMinutes} ${l10n.t('minutes')}';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
