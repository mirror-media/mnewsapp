abstract class TabStoryListEvents{}

class FetchStoryList extends TabStoryListEvents {}

class FetchNextPage extends TabStoryListEvents {
  final int loadingMorePage;

  FetchNextPage({this.loadingMorePage = 20});
}

class FetchStoryListByCategorySlug extends TabStoryListEvents {
  final String slug;

  FetchStoryListByCategorySlug(this.slug);
}

class FetchNextPageByCategorySlug extends TabStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByCategorySlug(this.slug, {this.loadingMorePage = 20});
}
