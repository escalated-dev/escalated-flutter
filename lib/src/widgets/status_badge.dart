import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final l10n = AppLocalizations.of(context);
    final displayLabel = label ?? l10n.t(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.badgeBorder,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}
