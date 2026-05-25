import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/firebaseMessagingHelper.dart';
import 'package:tv/mNewsApp.dart';
import 'package:tv/services/comscoreService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[prod-init] WidgetsFlutterBinding initialized');

  // 初始化環境
  Environment().initConfig(BuildFlavor.production);
  debugPrint('[prod-init] Environment configured');

  // iOS 要求追蹤權限
  if (Platform.isIOS) {
    debugPrint('[prod-init] Requesting ATT permission');
    await Future.delayed(const Duration(milliseconds: 1000));
    await AppTrackingTransparency.requestTrackingAuthorization();
    debugPrint('[prod-init] ATT permission request finished');
  }

  // 初始化第三方 SDK
  debugPrint('[prod-init] Initializing Mobile Ads');
  MobileAds.instance.initialize();
  debugPrint('[prod-init] Initializing Firebase');
  await Firebase.initializeApp();
  debugPrint('[prod-init] Firebase initialized');
  // 背景訊息 handler 必須在 runApp 之前、Firebase init 之後盡早註冊。
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  debugPrint('[prod-init] FCM background handler registered');
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  debugPrint('[prod-init] Crashlytics handler registered');

  // 初始化 Comscore (prod = 正式環境)
  debugPrint('[prod-init] Initializing Comscore');
  await ComscoreService.init(isProd: true);
  debugPrint('[prod-init] Comscore initialized');

  // 鎖定螢幕方向
  debugPrint('[prod-init] Setting preferred orientations');
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('[prod-init] Preferred orientations set');

  // 啟動 App
  debugPrint('[prod-init] Running app');
  runApp(MNewsApp());
}
