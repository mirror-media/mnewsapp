import 'package:flutter/material.dart';
import 'package:tv/pages/error/error400Widget.dart';
import 'package:tv/pages/error/error500Widget.dart';
import 'package:tv/pages/error/noSignalWidget.dart';

abstract class MNewException {
  var message;
  MNewException(this.message);
  
  Widget renderWidget({
    VoidCallback? onPressed,
    bool isNoButton = false,
    bool isColumn = false,
  });
}

class Error500Exception implements MNewException{
  var message;
  Error500Exception(this.message);

  @override
  Widget renderWidget({
    VoidCallback? onPressed,
    bool isNoButton = false,
    bool isColumn = false,
  }) => Error500Widget(isNoButton: isNoButton, isColumn: isColumn);
}

class Error400Exception implements MNewException{
  var message;
  Error400Exception(this.message);

  @override
  Widget renderWidget({
    VoidCallback? onPressed,
    bool isNoButton = false,
    bool isColumn = false,
  }) => Error400Widget(isNoButton: isNoButton, isColumn: isColumn);
}

class NoInternetException implements MNewException{
  var message;
  NoInternetException(this.message);

  @override
  Widget renderWidget({
    VoidCallback? onPressed,
    bool isNoButton = false,
    bool isColumn = false,
  }) => NoSignalWidget(onPressed: onPressed, isColumn: isColumn);
}

class NoServiceFoundException extends Error500Exception{
  NoServiceFoundException(message) : super(message);
}

class InvalidFormatException extends Error400Exception{
  InvalidFormatException(message) : super(message);
}

class UnknownException extends Error400Exception{
  UnknownException(message) : super(message);
}
