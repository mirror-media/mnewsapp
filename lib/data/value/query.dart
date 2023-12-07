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

  static String getVideoPostList = '''
  query {
    allPosts(
      where:{
        state:published,
        style_not_in:[wide,projects,script,campaign,readr],
        categories_some:{
            slug:"%s"
        }

    },
      skip:%d, 
      first: %d, 
      sortBy: [ publishTime_DESC ],
    ) {
      id
      slug
      name
      heroImage {
        urlMobileSized
      }
    }
 
  }
  ''';

  static String getShowsById ='''
  query {
      Show(
        where: {id:%s},
      ) {
        name
        introduction
        picture {
          urlMobileSized
        }
        playList01
        playList02
      }
    }
  ''';

}
