import 'package:comscore_analytics_flutter/comscore_analytics_flutter.dart';

import '../models/category.dart';

class ComscoreService {
  /// 初始化 Comscore SDK
  static Future<void> init({required bool isProd}) async {
    final publisher = await PublisherConfiguration.build(
      publisherId: "24318560", // C2 Value
      persistentLabels: {
        "env": isProd ? "prod" : "dev",
      },
      startLabels: {
        "app": "mnewsapp",
      },
    );

    Analytics.configuration.addClient(publisher);

    if (!isProd) {
      Analytics.configuration.enableImplementationValidationMode();
    }

    Analytics.start();
  }

  static void trackArticleView({
    required String articleId,
    required String title,
    required String category,
  }) {
    Analytics.notifyViewEvent(
      labels: {
        "ns_subcategory": category,
        "article_id": articleId,
        "article_title": title,
      },
    );
  }




  /// 記錄頁面瀏覽
  static void trackPage(String pageName) {
    Analytics.notifyViewEvent(
      labels: {
        "ns_content": pageName,
      },
    );
  }

  /// 記錄自訂事件
  static void trackEvent(String eventName, {Map<String, String>? extra}) {
    final labels = {
      "event": eventName,
      ...?extra,
    };
    Analytics.notifyHiddenEvent(labels: labels);
  }
}
