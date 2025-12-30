import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/misoSearchService.dart';
import 'package:tv/services/misoApiClient.dart';

abstract class SearchRepos {
  Future<List<StoryListItem>> searchNewsStoryByKeyword(
      String keyword, {
        int from = 0,
        int size = 20,
        String orderBy = 'relevance', // ✅ 新增
      });

  Future<List<StoryListItem>> searchNextPageByKeyword(
      String keyword, {
        int loadingMorePage = 20,
        String? orderBy, // ✅ 新增（不傳就沿用上一個）
      });

  int allStoryCount = 0;
}

class SearchServices implements SearchRepos {
  static const String _apiKey = 'IHtn9b9tfPsO1EQpGV74OMf2syhELb6XVZe8u9FT';
  static const String _anonymousId = 'tv_app';

  late final MisoSearchService _miso;

  int from = 0;
  int size = 20;

  // ✅ 記住目前排序，loading more 才會一致
  String _currentOrderBy = 'relevance';

  @override
  int allStoryCount = 0;

  SearchServices() {
    final client = MisoApiClient(apiKey: _apiKey);
    _miso = MisoSearchService(
      client: client,
      anonymousId: _anonymousId,
      userId: null,
    );
  }

  @override
  Future<List<StoryListItem>> searchNewsStoryByKeyword(
      String keyword, {
        int from = 0,
        int size = 20,
        String orderBy = 'relevance',
      }) async {
    // ✅ 如果排序變了，就強制回到第一頁
    if (orderBy != _currentOrderBy) {
      from = 0;
    }

    // ✅ 如果是第一頁搜尋，也把內部狀態重置成第一頁
    if (from == 0) {
      this.from = 0;
      this.size = size; // 通常就是 20
    } else {
      this.from = from;
      this.size = size;
    }

    _currentOrderBy = orderBy;

    final res = await _miso.search(
      keyword,
      start: this.from,
      rows: this.size,
      orderBy: _currentOrderBy,
    );

    allStoryCount = res.data.total ?? 0;

    final list = res.data.products.map((p) {
      return StoryListItem.fromJson({
        'product_id': p.productId,
        'title': p.title,
        'url': p.url,
        'cover_image': p.coverImage,
        'custom_attributes': p.customAttributes,
        'published_at': p.publishedAt,
      });
    }).toList();

    return list;
  }

  @override
  Future<List<StoryListItem>> searchNextPageByKeyword(
      String keyword, {
        int loadingMorePage = 20,
        String? orderBy,
      }) async {
    // ✅ 沒傳就沿用上一個排序；有傳就更新
    final nextOrderBy = orderBy ?? _currentOrderBy;

    // ✅ 如果有人在「下一頁」時突然切排序，那就直接回第一頁
    if (nextOrderBy != _currentOrderBy) {
      return searchNewsStoryByKeyword(
        keyword,
        from: 0,
        size: 20,
        orderBy: nextOrderBy,
      );
    }

    from += size;
    size = loadingMorePage;

    return searchNewsStoryByKeyword(
      keyword,
      from: from,
      size: size,
      orderBy: nextOrderBy,
    );
  }
}
