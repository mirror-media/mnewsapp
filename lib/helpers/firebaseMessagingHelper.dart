import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:tv/pages/storyPage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

class FirebaseMessagingHelper {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FirebaseMessagingHelper();

  configFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null &&
        initialMessage.data.containsKey('news_story_slug')) {
      Get.to(() => StoryPage(
            slug: initialMessage.data['news_story_slug'],
          ));
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.containsKey('news_story_slug')) {
        Get.to(() => StoryPage(
              slug: message.data['news_story_slug'],
            ));
      }
    });
  }

  subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  dispose() {}
}
