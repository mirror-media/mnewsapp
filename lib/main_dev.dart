import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/mNewsApp.dart';
import 'package:tv/services/comscoreService.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化環境
  Environment().initConfig(BuildFlavor.development);

  // iOS 要求追蹤權限
  if (Platform.isIOS) {
    await Future.delayed(const Duration(milliseconds: 1000));
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  // 初始化第三方 SDK
  MobileAds.instance.initialize();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // 初始化 Comscore (dev = 測試環境)
  await ComscoreService.init(isProd: true);

  // 鎖定螢幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 啟動 App
  runApp(MNewsApp());
}
