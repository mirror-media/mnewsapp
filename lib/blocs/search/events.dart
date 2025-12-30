abstract class SearchEvents {}

class SearchNewsStoryByKeyword extends SearchEvents {
  final String keyword;
  final String orderBy; // ✅ 新增

  SearchNewsStoryByKeyword(
      this.keyword, {
        this.orderBy = 'relevance',
      });

  @override
  String toString() =>
      'SearchNewsStoryByKeyword { keyword: $keyword, orderBy: $orderBy }';
}

class SearchNextPageByKeyword extends SearchEvents {
  final String keyword;
  final String? orderBy; // ✅ 新增（可選，不傳就沿用上一個）

  SearchNextPageByKeyword(
      this.keyword, {
        this.orderBy,
      });

  @override
  String toString() =>
      'SearchNextPageByKeyword { keyword: $keyword, orderBy: $orderBy }';
}

class ClearKeyword extends SearchEvents {
  @override
  String toString() => 'ClearKeyword';
}
