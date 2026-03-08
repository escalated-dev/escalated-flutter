import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/colors.dart';

class SatisfactionRating extends StatefulWidget {
  final void Function(int rating, String? comment) onSubmit;

  const SatisfactionRating({
    super.key,
    required this.onSubmit,
  });

  @override
  State<SatisfactionRating> createState() => _SatisfactionRatingState();
}

class _SatisfactionRatingState extends State<SatisfactionRating> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _ratingLabel(BuildContext context, int rating) {
    final l10n = AppLocalizations.of(context);
    switch (rating) {
      case 1:
        return l10n.t('terrible');
      case 2:
        return l10n.t('poor');
      case 3:
        return l10n.t('okay');
      case 4:
        return l10n.t('good');
      case 5:
        return l10n.t('excellent');
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_submitted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.statusResolved.withOpacity(0.08),
          borderRadius: AppRadius.cardBorder,
          border: Border.all(color: AppColors.statusResolved.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.statusResolved),
            const SizedBox(width: 8),
            Text(
              l10n.t('thank_you_feedback'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.statusResolved,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.04),
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('how_was_experience'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starNumber),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    starNumber <= _rating ? Icons.star : Icons.star_border,
                    size: 36,
                    color: starNumber <= _rating
                        ? const Color(0xFFFBBF24)
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  _ratingLabel(context, _rating),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.t('write_reply'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating > 0
                  ? () {
                      widget.onSubmit(
                        _rating,
                        _commentController.text.isNotEmpty
                            ? _commentController.text
                            : null,
                      );
                      setState(() => _submitted = true);
                    }
                  : null,
              child: Text(l10n.t('submit_rating')),
            ),
          ),
        ],
      ),
    );
  }
}
