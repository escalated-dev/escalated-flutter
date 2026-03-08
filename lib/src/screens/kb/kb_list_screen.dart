import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/article.dart';
import '../../providers/kb_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_shimmer.dart';

class KbListScreen extends ConsumerStatefulWidget {
  const KbListScreen({super.key});

  @override
  ConsumerState<KbListScreen> createState() => _KbListScreenState();
}

class _KbListScreenState extends ConsumerState<KbListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(kbListProvider.notifier);
      notifier.loadArticles(refresh: true);
      notifier.loadCategories();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(kbListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(kbListProvider.notifier)
          .setSearch(query.isEmpty ? null : query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(kbListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.knowledgeBase),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: l10n.t('search_articles'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(kbListProvider.notifier).setSearch(null);
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category filter chips
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: state.categoryId == null,
                      onSelected: (_) {
                        ref.read(kbListProvider.notifier).setCategory(null);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: state.categoryId == null
                            ? AppColors.primary
                            : null,
                        fontWeight: state.categoryId == null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  ...state.categories.map((cat) {
                    final catId = cat['id'] as int;
                    final catName = cat['name'] as String;
                    final isSelected = state.categoryId == catId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(catName),
                        selected: isSelected,
                        onSelected: (_) {
                          ref
                              .read(kbListProvider.notifier)
                              .setCategory(isSelected ? null : catId);
                        },
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Article list
          Expanded(
            child: _buildBody(state, l10n, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(KbListState state, AppLocalizations l10n, bool isDark) {
    if (state.isLoading && state.articles.isEmpty) {
      return const LoadingShimmer();
    }

    if (state.error != null && state.articles.isEmpty) {
      return ErrorView(
        message: state.error,
        onRetry: () =>
            ref.read(kbListProvider.notifier).loadArticles(refresh: true),
      );
    }

    if (!state.isLoading && state.articles.isEmpty) {
      return EmptyState(
        icon: Icons.menu_book_outlined,
        title: l10n.t('no_articles'),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(kbListProvider.notifier).loadArticles(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.articles.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _ArticleCard(article: state.articles[index]);
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: AppRadius.cardBorder,
        onTap: () => context.go('/kb/${article.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.category != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: AppRadius.badgeBorder,
                    ),
                    child: Text(
                      article.category!.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (article.excerpt != null && article.excerpt!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  article.excerpt!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${article.views} ${l10n.t('views')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
