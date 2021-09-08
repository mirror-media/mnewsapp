import 'package:flutter/material.dart';
import 'package:tv/baseConfig.dart';
import 'package:tv/mNewsApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BaseConfig.init(flavor: BuildFlavor.development);

  runApp(MNewsApp());
}
