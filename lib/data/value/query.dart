class QueryCommand {

  static String getYoutubeStreamList = '''
   query{
    allVideos( 
        where: {
            name_contains:"%s"
            state_in:published
        }
        sortBy: [ publishTime_DESC ]
    ){
        name
        youtubeUrl
        state
    }
  }
  ''';
}