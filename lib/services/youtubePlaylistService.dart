import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class YoutubePlaylistRepos {
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistId(
    String playlistId, 
    {int maxResults = 5}
  );
}

class YoutubePlaylistServices implements YoutubePlaylistRepos{
  ApiBaseHelper _helper = ApiBaseHelper();
  
  @override
  Future<YoutubePlaylistItemList> fetchSnippetByPlaylistId(String playlistId, {int maxResults = 5}) async{
    final jsonResponse = await _helper.getByUrl(
      youtubeApi+'/playlistItems?part=snippet&playlistId=$playlistId&maxResults=$maxResults'
    );

    YoutubePlaylistItemList youtubePlaylistItemList = YoutubePlaylistItemList.fromJson(
      jsonResponse['items']
    );
    return youtubePlaylistItemList;
  }
}