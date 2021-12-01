import 'package:firebase_analytics/firebase_analytics.dart';

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
}
