enum Flavor { dev, prod }

abstract class BaseConfig {
  Flavor get flavor;
  String get graphqlApi;
  String get searchApi;
  String get youtubeApi;
  String get mirrorNewsDefaultImageUrl;
  String get newsPopularListUrl;
  String get videoPopularListUrl;
  String get ombudsAppealUrl;
  String get ombudsvideoRecorderUrl;
  String get ombudsReportsUrl;
  String get privacyPolicyUrl;
  String get categoriesUrl;
  String get programListUrl;
  String get mNewsWebsiteLink;
  String get mNewsLivePostId;
  String get podcastAPIUrl;
  // in data constants
  List get mNewsSectionList;
}
