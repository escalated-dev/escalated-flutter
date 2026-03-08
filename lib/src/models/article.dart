class ArticleCategory {
  final int id;
  final String name;
  final String? slug;

  const ArticleCategory({
    required this.id,
    required this.name,
    this.slug,
  });

  factory ArticleCategory.fromJson(Map<String, dynamic> json) {
    return ArticleCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (slug != null) 'slug': slug,
    };
  }
}

class Article {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? body;
  final ArticleCategory? category;
  final int views;
  final int helpfulCount;
  final int notHelpfulCount;
  final bool isPublished;
  final List<Article> relatedArticles;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Article({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.body,
    this.category,
    required this.views,
    required this.helpfulCount,
    required this.notHelpfulCount,
    required this.isPublished,
    this.relatedArticles = const [],
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      excerpt: json['excerpt'] as String?,
      body: json['body'] as String?,
      category: json['category'] != null
          ? ArticleCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      views: json['views'] as int? ?? 0,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      notHelpfulCount: json['not_helpful_count'] as int? ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
      relatedArticles: (json['related_articles'] as List<dynamic>?)
              ?.map((a) => Article.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      if (excerpt != null) 'excerpt': excerpt,
      if (body != null) 'body': body,
      if (category != null) 'category': category!.toJson(),
      'views': views,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'is_published': isPublished,
      'related_articles': relatedArticles.map((a) => a.toJson()).toList(),
      if (publishedAt != null) 'published_at': publishedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
