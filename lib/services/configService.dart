import 'package:tv/helpers/firebaseMessagingHelper.dart';

abstract class ConfigRepos {
  Future<bool> loadTheConfig();
}

class ConfigServices implements ConfigRepos {
  @override
  Future<bool> loadTheConfig() async {
    FirebaseMessagingHelper firebaseMessagingHelper = FirebaseMessagingHelper();
    await firebaseMessagingHelper.configFirebaseMessaging();
    return true;
  }
}
