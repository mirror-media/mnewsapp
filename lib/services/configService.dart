import 'package:firebase_core/firebase_core.dart';
import 'package:tv/helpers/firebaseMessagingHelper.dart';

abstract class ConfigRepos {
  Future<bool> loadTheConfig();
}

class ConfigServices implements ConfigRepos{
  @override
  Future<bool> loadTheConfig() async{
    await Firebase.initializeApp();
    
    FirebaseMessagingHelper firebaseMessagingHelper = FirebaseMessagingHelper();
    await firebaseMessagingHelper.configFirebaseMessaging();
    return true;
  }
}