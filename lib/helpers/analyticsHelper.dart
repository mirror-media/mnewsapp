import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tv/models/category.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static sendScreenView({required String screenName}) async {
    await analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName, // 可自訂或與 screenName 相同
    );
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
    required List<Category>? category,
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

  static logClick({
    required String slug,
    required String title,
    required String location,
  }) async {
    await analytics.logEvent(name: 'click', parameters: {
      'location': location,
      'slug': slug,
      'title': title,
    });
  }

  static logShare({
    required String name,
    required String type,
  }) async {
    await analytics.logShare(contentType: type, itemId: name, method: "");
  }

  static logElectionEvent({required String eventName}) async {
    await analytics.logEvent(name: eventName);
  }
}
