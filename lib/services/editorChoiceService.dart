import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class EditorChoiceRepos {
  Future<StoryListItemList> fetchEditorChoiceList();
  Future<StoryListItemList> fetchVideoEditorChoiceList();
}

class EditorChoiceServices implements EditorChoiceRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<StoryListItemList> fetchEditorChoiceList() async {
    final key = 'fetchEditorChoiceList';

    String query = """
    query(
      \$where: EditorChoiceWhereInput, 
      \$first: Int){
      allEditorChoices(
        where: \$where, 
        first: \$first, 
        sortBy: [sortOrder_ASC, createdAt_DESC]
      ) {
        choice {
          id
          name
          slug
          style
          heroImage {
            urlMobileSized
          }
          heroVideo {
            coverPhoto {
              urlMobileSized
            }
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "choice": {"state": "published"}
      },
      "first": 10
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: editorChoiceCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<dynamic> parsedJson = List.empty(growable: true);
    for (int i = 0; i < jsonResponse['data']['allEditorChoices'].length; i++) {
      parsedJson.add(jsonResponse['data']['allEditorChoices'][i]['choice']);
    }
    StoryListItemList editorChoiceList = StoryListItemList.fromJson(parsedJson);
    return editorChoiceList;
  }

  @override
  Future<StoryListItemList> fetchVideoEditorChoiceList() async {
    final key = 'fetchVideoEditorChoiceList';

    String query = """
    query(
      \$where: VideoEditorChoiceWhereInput, 
      \$first: Int
    ){
      allVideoEditorChoices(
        where: \$where, 
        first: \$first, 
        sortBy: [order_ASC, createdAt_DESC]
      ) {
        videoEditor {
          id
          name
          slug
          style
          heroImage {
            urlMobileSized
          }
          heroVideo {
            coverPhoto {
              urlMobileSized
            }
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "videoEditor": {"state": "published", "style": "videoNews"}
      },
      "first": 10
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: videoEditorChoiceCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<dynamic> parsedJson = List.empty(growable: true);
    for (int i = 0;
        i < jsonResponse['data']['allVideoEditorChoices'].length;
        i++) {
      parsedJson
          .add(jsonResponse['data']['allVideoEditorChoices'][i]['videoEditor']);
    }
    StoryListItemList editorChoiceList = StoryListItemList.fromJson(parsedJson);
    return editorChoiceList;
  }
}
