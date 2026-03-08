class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return PaginatedResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage:
          (meta?['current_page'] ?? json['current_page'] ?? 1) as int,
      lastPage: (meta?['last_page'] ?? json['last_page'] ?? 1) as int,
      perPage: (meta?['per_page'] ?? json['per_page'] ?? 15) as int,
      total: (meta?['total'] ?? json['total'] ?? 0) as int,
    );
  }

  bool get hasMore => currentPage < lastPage;

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'meta': {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
      },
    };
  }
}
