abstract class SearchEvents {}

class SearchNewsStoryByKeyword extends SearchEvents {
  final String keyword;
  SearchNewsStoryByKeyword(this.keyword);

  @override
  String toString() => 'SearchNewsStoryByKeyword { keyword: $keyword }';
}

class SearchNextPageByKeyword extends SearchEvents {
  final String keyword;
  SearchNextPageByKeyword(this.keyword);

  @override
  String toString() => 'SearchNextPageByKeyword { keyword: $keyword }';
}

class ClearKeyword extends SearchEvents {
  @override
  String toString() => 'ClearKeyword';
}
