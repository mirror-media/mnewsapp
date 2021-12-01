import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();

  static sendScreenView({required String screenName}) async {
    await analytics.setCurrentScreen(screenName: screenName);
  }
}
