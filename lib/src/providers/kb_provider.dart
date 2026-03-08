import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/article.dart';
import 'auth_provider.dart';

class KbListState {
  final List<Article> articles;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final int? categoryId;
  final List<Map<String, dynamic>> categories;

  const KbListState({
    this.articles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.categoryId,
    this.categories = const [],
  });

  KbListState copyWith({
    List<Article>? articles,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    int? categoryId,
    List<Map<String, dynamic>>? categories,
    bool clearCategory = false,
  }) {
    return KbListState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categories: categories ?? this.categories,
    );
  }
}

class KbListNotifier extends StateNotifier<KbListState> {
  final Ref _ref;

  KbListNotifier(this._ref) : super(const KbListState());

  Future<void> loadArticles({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        articles: [],
        hasMore: true,
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final api = _ref.read(apiServiceProvider);
      final response = await api.getArticles(
        page: 1,
        search: state.searchQuery,
        categoryId: state.categoryId,
      );
      state = state.copyWith(
        articles: response.data,
        isLoading: false,
        currentPage: response.currentPage,
        hasMore: response.hasMore,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] as String? ??
            'Failed to load articles.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final api = _ref.read(apiServiceProvider);
      final nextPage = state.currentPage + 1;
      final response = await api.getArticles(
        page: nextPage,
        search: state.searchQuery,
        categoryId: state.categoryId,
      );
      state = state.copyWith(
        articles: [...state.articles, ...response.data],
        isLoadingMore: false,
        currentPage: response.currentPage,
        hasMore: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> loadCategories() async {
    try {
      final api = _ref.read(apiServiceProvider);
      final categories = await api.getCategories();
      state = state.copyWith(categories: categories);
    } catch (_) {
      // Silently fail for categories
    }
  }

  void setSearch(String? query) {
    state = state.copyWith(searchQuery: query);
    loadArticles(refresh: true);
  }

  void setCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
    loadArticles(refresh: true);
  }
}

final kbListProvider =
    StateNotifierProvider<KbListNotifier, KbListState>((ref) {
  return KbListNotifier(ref);
});

// Article detail
class ArticleDetailState {
  final Article? article;
  final bool isLoading;
  final String? error;

  const ArticleDetailState({
    this.article,
    this.isLoading = false,
    this.error,
  });

  ArticleDetailState copyWith({
    Article? article,
    bool? isLoading,
    String? error,
  }) {
    return ArticleDetailState(
      article: article ?? this.article,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ArticleDetailNotifier extends StateNotifier<ArticleDetailState> {
  final Ref _ref;

  ArticleDetailNotifier(this._ref) : super(const ArticleDetailState());

  Future<void> loadArticle(String slug) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final api = _ref.read(apiServiceProvider);
      final article = await api.getArticle(slug);
      state = state.copyWith(article: article, isLoading: false);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['message'] as String? ??
            'Failed to load article.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<bool> rateArticle({
    required String slug,
    required bool helpful,
  }) async {
    try {
      final api = _ref.read(apiServiceProvider);
      await api.rateArticle(slug: slug, helpful: helpful);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final articleDetailProvider =
    StateNotifierProvider<ArticleDetailNotifier, ArticleDetailState>((ref) {
  return ArticleDetailNotifier(ref);
});
