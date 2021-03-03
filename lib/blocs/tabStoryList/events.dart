import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/tabStoryListService.dart';

abstract class TabStoryListEvents{
  StoryListItemList storyListItemList;
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos);
}

class FetchStoryList extends TabStoryListEvents {
  @override
  String toString() => 'FetchStoryList';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    yield TabStoryListLoading();
    storyListItemList = await tabStoryListRepos.fetchStoryList();
    yield TabStoryListLoaded(storyListItemList: storyListItemList);
  }
}

class FetchNextPage extends TabStoryListEvents {
  final int loadingMorePage;

  FetchNextPage({this.loadingMorePage = 20});

  @override
  String toString() => 'FetchNextPage { loadingMorePage: $loadingMorePage }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
    StoryListItemList newStoryListItemList = await tabStoryListRepos.fetchNextPage(
      loadingMorePage: loadingMorePage
    );
    storyListItemList.addAll(newStoryListItemList);
    yield TabStoryListLoaded(storyListItemList: storyListItemList);
  }
}

class FetchStoryListByCategorySlug extends TabStoryListEvents {
  final String slug;

  FetchStoryListByCategorySlug(this.slug);

  @override
  String toString() => 'FetchStoryListByCategorySlug { slug: $slug }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    yield TabStoryListLoading();
    storyListItemList = await tabStoryListRepos.fetchStoryListByCategorySlug(slug);
    yield TabStoryListLoaded(storyListItemList: storyListItemList);
  }
}

class FetchNextPageByCategorySlug extends TabStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByCategorySlug(this.slug, {this.loadingMorePage = 20});

  @override
  String toString() => 'FetchNextPageByCategorySlug { slug: $slug, loadingMorePage: $loadingMorePage }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
    StoryListItemList newStoryListItemList = await tabStoryListRepos.fetchNextPageByCategorySlug(
      slug, 
      loadingMorePage: loadingMorePage
    );
    storyListItemList.addAll(newStoryListItemList);
    yield TabStoryListLoaded(storyListItemList: storyListItemList);
  }
}
