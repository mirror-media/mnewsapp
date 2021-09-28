import 'package:flutter/material.dart';

abstract class ConfigEvents {
  final BuildContext context;
  ConfigEvents(this.context);
}

class LoadingConfig extends ConfigEvents {
  final BuildContext context;
  LoadingConfig(this.context) : super(context);

  @override
  String toString() => 'LoadingConfig';
}
