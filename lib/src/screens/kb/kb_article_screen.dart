import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/kb_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_shimmer.dart';

class KbArticleScreen extends ConsumerStatefulWidget {
  final String slug;

  const KbArticleScreen({super.key, required this.slug});

  @override
  ConsumerState<KbArticleScreen> createState() => _KbArticleScreenState();
}

class _KbArticleScreenState extends ConsumerState<KbArticleScreen> {
  bool? _ratedHelpful;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(articleDetailProvider.notifier).loadArticle(widget.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(articleDetailProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.knowledgeBase),
      ),
      body: _buildBody(state, l10n, isDark),
    );
  }

  Widget _buildBody(
      ArticleDetailState state, AppLocalizations l10n, bool isDark) {
    if (state.isLoading && state.article == null) {
      return const ShimmerCard();
    }

    if (state.error != null && state.article == null) {
      return ErrorView(
        message: state.error,
        onRetry: () =>
            ref.read(articleDetailProvider.notifier).loadArticle(widget.slug),
      );
    }

    final article = state.article;
    if (article == null) return const ShimmerCard();

    final dateFormat = DateFormat('MMM d, y');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          if (article.category != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: AppRadius.badgeBorder,
                ),
                child: Text(
                  article.category!.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

          // Title
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Meta row
          Row(
            children: [
              Icon(Icons.visibility_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                '${article.views} ${l10n.t('views')}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (article.publishedAt != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.calendar_today_outlined,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  '${l10n.t('published')} ${dateFormat.format(article.publishedAt!.toLocal())}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // HTML body
          if (article.body != null && article.body!.isNotEmpty)
            Html(
              data: article.body!,
              style: {
                'body': Style(
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  fontSize: FontSize(15),
                  lineHeight: const LineHeight(1.6),
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                'p': Style(
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                'h1': Style(
                  fontSize: FontSize(22),
                  fontWeight: FontWeight.w700,
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                ),
                'h2': Style(
                  fontSize: FontSize(19),
                  fontWeight: FontWeight.w700,
                  margin: const EdgeInsets.only(top: 14, bottom: 8),
                ),
                'h3': Style(
                  fontSize: FontSize(17),
                  fontWeight: FontWeight.w600,
                  margin: const EdgeInsets.only(top: 12, bottom: 6),
                ),
                'a': Style(
                  color: AppColors.primary,
                  textDecoration: TextDecoration.none,
                ),
                'code': Style(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  fontFamily: 'monospace',
                  fontSize: FontSize(13),
                ),
                'pre': Style(
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.withOpacity(0.08),
                  padding: const EdgeInsets.all(12),
                ),
                'blockquote': Style(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 12),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                'ul': Style(
                  margin: const EdgeInsets.only(bottom: 12),
                ),
                'ol': Style(
                  margin: const EdgeInsets.only(bottom: 12),
                ),
              },
            ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Helpful / Not Helpful buttons
          if (_ratedHelpful == null)
            Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    'Was this article helpful?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final success = await ref
                              .read(articleDetailProvider.notifier)
                              .rateArticle(
                                  slug: widget.slug, helpful: true);
                          if (success && mounted) {
                            setState(() => _ratedHelpful = true);
                          }
                        },
                        icon: const Icon(Icons.thumb_up_outlined, size: 18),
                        label: Text(l10n.t('helpful')),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final success = await ref
                              .read(articleDetailProvider.notifier)
                              .rateArticle(
                                  slug: widget.slug, helpful: false);
                          if (success && mounted) {
                            setState(() => _ratedHelpful = false);
                          }
                        },
                        icon:
                            const Icon(Icons.thumb_down_outlined, size: 18),
                        label: Text(l10n.t('not_helpful')),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusResolved.withOpacity(0.08),
                borderRadius: AppRadius.cardBorder,
                border: Border.all(
                    color: AppColors.statusResolved.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.statusResolved),
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
            ),

          // Related articles
          if (article.relatedArticles.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              l10n.t('related_articles'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...article.relatedArticles.map((related) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      related.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => context.go('/kb/${related.slug}'),
                  ),
                )),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
