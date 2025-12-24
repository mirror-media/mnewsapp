import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/misoSearchService.dart';
import 'package:tv/services/misoApiClient.dart';

abstract class SearchRepos {
  Future<List<StoryListItem>> searchNewsStoryByKeyword(
      String keyword, {
        int from = 0,
        int size = 20,
      });

  Future<List<StoryListItem>> searchNextPageByKeyword(
      String keyword, {
        int loadingMorePage = 20,
      });

  int allStoryCount = 0;
}

class SearchServices implements SearchRepos {
  static const String _apiKey = 'IHtn9b9tfPsO1EQpGV74OMf2syhELb6XVZe8u9FT';
  static const String _anonymousId = 'tv_app';

  late final MisoSearchService _miso;

  int from = 0;
  int size = 20;

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
      }) async {
    this.from = from;
    this.size = size;


    final res = await _miso.search(
      keyword,
      start: from,
      rows: size,
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
      }) async {
    from += size;
    size = loadingMorePage;
    return searchNewsStoryByKeyword(keyword, from: from, size: size);
  }
}