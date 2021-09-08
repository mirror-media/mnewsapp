import 'dart:convert';

import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class SearchRepos {
  Future<StoryListItemList> searchNewsStoryByKeyword(String keyword,
      {int from = 0, int size = 20});
  Future<StoryListItemList> searchNextPageByKeyword(String keyword,
      {int loadingMorePage = 20});
}

class SearchServices implements SearchRepos {
  ApiBaseHelper _helper = ApiBaseHelper();
  int from = 0, size = 20;

  @override
  Future<StoryListItemList> searchNewsStoryByKeyword(String keyword,
      {int from = 0, int size = 20}) async {
    this.from = from;
    this.size = size;

    var query = {"query": keyword, "from": from, "size": size};

    final jsonResponse = await _helper.postByUrl(
        baseConfig!.searchApi, jsonEncode(query),
        headers: {"Content-Type": "application/json"});

    StoryListItemList storyListItemList =
        StoryListItemList.fromJson(jsonResponse["body"]["hits"]["hits"]);
    storyListItemList.allStoryCount =
        jsonResponse["body"]["hits"]["total"]["value"];

    return storyListItemList;
  }

  @override
  Future<StoryListItemList> searchNextPageByKeyword(String keyword,
      {int loadingMorePage = 20}) async {
    from = from + size;
    size = loadingMorePage;
    return await searchNewsStoryByKeyword(keyword, from: from, size: size);
  }
}
