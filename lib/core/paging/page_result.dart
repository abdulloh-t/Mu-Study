class PageResult<T> {
  const PageResult({
    required this.items,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<T> items;
  final bool hasMore;
  final bool loadingMore;

  static const int pageSize = 40;

  static int fetchSize(int pageSize) => pageSize + 1;

  static PageResult<T> fromFetch<T>(
    List<T> fetched, {
    int pageSize = PageResult.pageSize,
  }) {
    final hasMore = fetched.length > pageSize;
    final items = hasMore ? fetched.sublist(0, pageSize) : fetched;
    return PageResult(items: items, hasMore: hasMore);
  }

  PageResult<T> copyWith({List<T>? items, bool? hasMore, bool? loadingMore}) {
    return PageResult(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }

  PageResult<T> append(List<T> next, {required bool hasMore}) {
    return PageResult(items: [...items, ...next], hasMore: hasMore);
  }
}
