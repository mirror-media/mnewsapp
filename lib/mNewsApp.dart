import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tv/blocs/config/bloc.dart';
import 'package:tv/controller/interstitialAdController.dart';
import 'package:tv/controller/textScaleFactorController.dart';
import 'package:tv/helpers/analyticsHelper.dart';
import 'package:tv/home_binding.dart';
import 'package:tv/initialApp.dart';
import 'package:tv/services/configService.dart';

class MNewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.logAppOpen();
    Get.put<InterstitialAdController>(
      InterstitialAdController(),
      permanent: true,
    );
    Get.put<TextScaleFactorController>(
      TextScaleFactorController(),
      permanent: true,
    );
    return GetMaterialApp(
      title: 'mnews',
      builder: (context, widget) {
        if (widget == null) {
          return Container();
        }
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: widget,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''),
        Locale('zh', 'TW'),
        Locale('zh', ''),
      ],
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en'),
      initialBinding: HomeBinding(),
      home: BlocProvider(
        create: (context) => ConfigBloc(configRepos: ConfigServices()),
        child: InitialApp(),
      ),
    );
  }
}
