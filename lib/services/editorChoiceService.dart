import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';

abstract class EditorChoiceRepos {
  Future<List<StoryListItem>> fetchEditorChoiceList();
  Future<List<StoryListItem>> fetchVideoEditorChoiceList();
}

class EditorChoiceServices implements EditorChoiceRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  @override
  Future<List<StoryListItem>> fetchEditorChoiceList() async {
    final key = 'fetchEditorChoiceList';

    const String query = """
  query(
    \$where: EditorChoiceWhereInput,
    \$take: Int
  ) {
    editorChoices(
      where: \$where,
      take: \$take,
      orderBy: [{ sortOrder: asc }, { createdAt: desc }]
    ) {
      choice {
        id
        name
        slug
        style
        heroImage {
          imageApiData
        }
        heroVideo {
          coverPhoto {
            imageApiData
          }
        }
      }
    }
  }
  """;

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "choice": {
          "state": {"equals": "published"}
        }
      },
      "take": 10,
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    print('===== fetchEditorChoiceList NEW VERSION =====');
    print('===== fetchEditorChoiceList graphqlApi =====');
    print(Environment().config.graphqlApi);
    print('===== fetchEditorChoiceList request body =====');
    print(jsonEncode(graphqlBody.toJson()));

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: editorChoiceCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    print('===== fetchEditorChoiceList response =====');
    print(jsonResponse);

    final List<dynamic> editorChoices =
        (jsonResponse['data']?['editorChoices'] as List?) ?? [];

    final List<dynamic> parsedJson = editorChoices
        .map((item) => item['choice'])
        .where((item) => item != null)
        .toList();

    return parsedJson
        .map((editorChoice) => StoryListItem.fromJson(editorChoice))
        .toList();
  }

  @override
  Future<List<StoryListItem>> fetchVideoEditorChoiceList() async {
    final key = 'fetchVideoEditorChoiceList';

    const String query = """
    query(
      \$where: VideoEditorChoiceWhereInput,
      \$take: Int
    ) {
      videoEditorChoices(
        where: \$where,
        take: \$take,
        orderBy: [{ order: asc }, { createdAt: desc }]
      ) {
        videoEditor {
          id
          name
          slug
          style
          heroImage {
            imageApiData
          }
          heroVideo {
            coverPhoto {
              imageApiData
            }
          }
        }
      }
    }
    """;

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "videoEditor": {
          "state": {"equals": "published"},
          "style": {"equals": "videoNews"}
        }
      },
      "take": 10,
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: videoEditorChoiceCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final List<dynamic> parsedJson = [];
    for (int i = 0;
    i < jsonResponse['data']['videoEditorChoices'].length;
    i++) {
      parsedJson.add(jsonResponse['data']['videoEditorChoices'][i]['videoEditor']);
    }

    final List<StoryListItem> editorChoiceList = List<StoryListItem>.from(
      parsedJson.map((editorChoice) => StoryListItem.fromJson(editorChoice)),
    );

    return editorChoiceList;
  }
}