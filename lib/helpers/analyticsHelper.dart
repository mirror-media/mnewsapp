import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tv/models/categoryList.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  static sendScreenView({required String screenName}) async {
    await analytics.setCurrentScreen(screenName: screenName);
  }

  static logAppOpen() async {
    await analytics.logAppOpen();
  }

  static logSearch({required String searchText}) async {
    await analytics.logSearch(searchTerm: searchText);
  }

  static logStory({
    required String slug,
    required String title,
    required CategoryList? category,
  }) async {
    String categoryName = '';
    if (category != null) {
      for (var item in category) {
        categoryName = categoryName + item.name + ',';
      }
    }
    await analytics.logEvent(name: 'open_story', parameters: {
      'slug': slug,
      'title': title,
      'category': categoryName,
    });
  }
}
