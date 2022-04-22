import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/storyListItem.dart';

abstract class SearchRepos {
  Future<List<StoryListItem>> searchNewsStoryByKeyword(String keyword,
      {int from = 0, int size = 20});
  Future<List<StoryListItem>> searchNextPageByKeyword(String keyword,
      {int loadingMorePage = 20});
  int allStoryCount = 0;
}

class SearchServices implements SearchRepos {
  ApiBaseHelper _helper = ApiBaseHelper();
  int from = 0, size = 20;
  @override
  int allStoryCount = 0;

  @override
  Future<List<StoryListItem>> searchNewsStoryByKeyword(String keyword,
      {int from = 0, int size = 20}) async {
    this.from = from;
    this.size = size;

    var query = {"query": keyword, "from": from, "size": size};

    final jsonResponse = await _helper.postByUrl(
        Environment().config.searchApi, jsonEncode(query),
        headers: {"Content-Type": "application/json"});

    List<StoryListItem> storyListItemList = List<StoryListItem>.from(
        jsonResponse["body"]["hits"]["hits"]
            .map((post) => StoryListItem.fromJson(post)));

    allStoryCount = jsonResponse["body"]["hits"]["total"]["value"];

    return storyListItemList;
  }

  @override
  Future<List<StoryListItem>> searchNextPageByKeyword(String keyword,
      {int loadingMorePage = 20}) async {
    from = from + size;
    size = loadingMorePage;
    return await searchNewsStoryByKeyword(keyword, from: from, size: size);
  }
}
