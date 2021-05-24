import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class SearchRepos {
  Future<StoryListItemList> searchNewsStoryByKeyword(String keyword, {int from = 0, int size = 20});
}

class SearchServices implements SearchRepos{
  ApiBaseHelper _helper = ApiBaseHelper();
  
  @override
  Future<StoryListItemList> searchNewsStoryByKeyword(String keyword, {int from = 0, int size = 20}) async{
    var query = {
      "query": keyword,
      "from": from,
      "size": size
    };

    final jsonResponse = await _helper.postByUrl(
      searchApi,
      jsonEncode(query),
      headers: {
        "Content-Type": "application/json"
      }
    );

    StoryListItemList storyListItemList = StoryListItemList.fromJson(
      jsonResponse["body"]["hits"]["hits"]
    );
    storyListItemList.allStoryCount = jsonResponse["body"]["hits"]["total"]["value"];
    
    return storyListItemList;
  }
}