import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/blocs/config/bloc.dart';
import 'package:tv/blocs/config/events.dart';
import 'package:tv/blocs/config/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/pages/configPage.dart';
import 'package:tv/pages/homePage.dart';
import 'package:upgrader/upgrader.dart';

import 'blocs/section/section_cubit.dart';
import 'helpers/updateMessages.dart';

class InitialApp extends StatefulWidget {
  @override
  _InitialAppState createState() => _InitialAppState();
}

class _InitialAppState extends State<InitialApp> {
  @override
  void initState() {
    _loadingConfig();
    super.initState();
  }

  _loadingConfig() async {
    context.read<ConfigBloc>().add(LoadingConfig(context));
    MobileAds.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
        builder: (BuildContext context, ConfigState state) {
      if (state is ConfigError) {
        final error = state.error;
        print('ConfigError: ${error.message}');
        return _errorMessage();
      }
      if (state is ConfigLoaded) {
        return UpgradeAlert(
          upgrader: Upgrader(
            minAppVersion: state.minAppVersion,
            messages: UpdateMessages(),
            dialogStyle: Platform.isAndroid
                ? UpgradeDialogStyle.material
                : UpgradeDialogStyle.cupertino,
          ),
          child: BlocProvider(
            create: (_) => SectionCubit(),
            child: HomePage(
              appVersion: state.appVersion,
            ),
          ),
        );
      }

      // state is Init, loading, or other
      return ConfigPage();
    });
  }

  Widget _errorMessage() {
    return Scaffold(
      backgroundColor: themeColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              logoPng,
              scale: 4.0,
            ),
            SizedBox(
              height: 20,
            ),
            Text('載入失敗',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                )),
            Text('請檢查網路連線後再重新開啟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                )),
          ],
        ),
      ),
    );
  }
}
