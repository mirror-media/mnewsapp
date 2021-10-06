import 'package:flutter/material.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/mNewsApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment().initConfig(BuildFlavor.production);

  runApp(MNewsApp());
}
