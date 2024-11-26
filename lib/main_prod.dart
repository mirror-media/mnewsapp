import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/mNewsApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment().initConfig(BuildFlavor.production);
  if (Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 1000));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
  MobileAds.instance.initialize();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MNewsApp());
  });
}
