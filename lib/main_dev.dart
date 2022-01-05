import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/mNewsApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment().initConfig(BuildFlavor.development);
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MNewsApp());
  });
}
