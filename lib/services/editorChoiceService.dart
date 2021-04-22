import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class EditorChoiceRepos {
  Future<StoryListItemList> fetchEditorChoiceList();
}

class EditorChoiceServices implements EditorChoiceRepos{
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<StoryListItemList> fetchEditorChoiceList() async {
    String query = 
    """
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
        "choice": {
          "state": "published"
        }
      },
      "first": 10
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByUrl(
      graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    List<dynamic> parsedJson = List<dynamic>();
    for(int i=0; i<jsonResponse['data']['allEditorChoices'].length; i++) {
      parsedJson.add(jsonResponse['data']['allEditorChoices'][i]['choice']);
    }
    StoryListItemList editorChoiceList = StoryListItemList.fromJson(parsedJson);    
    return editorChoiceList;
  }
}
