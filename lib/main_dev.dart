import 'package:flutter/material.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/mNewsApp.dart';

import 'helpers/adHelper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  BaseConfig.init(flavor: BuildFlavor.development);
  AdHelper.init();

  runApp(MNewsApp());
}