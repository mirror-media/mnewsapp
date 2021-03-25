import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class YoutubePlaylistRepos {
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistId(String playlistId);
}

class YoutubePlaylistServices implements YoutubePlaylistRepos{
  ApiBaseHelper _helper = ApiBaseHelper();
  
  @override
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistId(String playlistId) async{
    final jsonResponse = await _helper.getByUrl(
      youtubeApi+'/playlistItems?part=snippet&playlistId=$playlistId'
    );

    YoutubePlaylistItemList youtubePlaylistItemList = YoutubePlaylistItemList.fromJson(
      jsonResponse['items']
    );
    return youtubePlaylistItemList;
  }
}