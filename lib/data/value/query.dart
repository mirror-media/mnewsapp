class QueryCommand {
  static String getYoutubeStreamList = '''
   query{
    videos( 
      where: {
        name: { contains: "%s" }
        state: { equals: "published" }
      }
      orderBy: [{ publishTime: desc }]
    ){
      name
      youtubeUrl
      state
    }
  }
  ''';

  static String getVideoPostList = '''
  query {
    posts(
      where:{
        state: { equals: "published" }
        style: {
          in: ["videoNews"]
          notIn: ["wide","projects","script","campaign","readr"]
        }
        categories:{
          some:{
            slug:{ equals:"%s" }
          }
        }
      }
      skip:%d
      take:%d
      orderBy: [{ publishTime: desc }]
    ) {
      id
      slug
      name
      heroImage {
        imageApiData
      }
    }
  }
  ''';

  static String getShowBySlug = '''
  query {
    shows(
      where: { slug: { equals: "%s" } }
    ) {
      slug
      name
      introduction
      picture {
        imageApiData
      }
      playList01
      playList02
    }
  }
  ''';

  static String getLatestArticles = '''
    query {
      posts(
        where:{
          state: { equals: "published" }
          style: {
            notIn:["wide","projects","script","campaign","readr"]
          }
        }
        skip:%d
        take:%d
        orderBy: [{ publishTime: desc }]
      ) {
        id
        slug
        name
        style
        categories{
          name
          id
          slug
        }
        heroImage {
          imageApiData
        }
      }
    }
  ''';

  static const String getSalesArticles = '''
  query{
    sales(
      orderBy:[{ sortOrder: asc }]
    ){
      adPost{
        id
        slug
        name
        style
        categories{
          name
          id
          slug
        }
        heroImage {
          imageApiData
        }
      }
    }
  }
  ''';
}