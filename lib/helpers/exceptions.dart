import 'package:flutter/material.dart';
import 'package:tv/pages/error/error400Widget.dart';
import 'package:tv/pages/error/error500Widget.dart';
import 'package:tv/pages/error/noSignalWidget.dart';

abstract class MNewException {
  var message;
  MNewException(this.message);
  
  Widget renderWidget({VoidCallback onPressed});
}

class Error500Exception implements MNewException{
  var message;
  Error500Exception(this.message);

  @override
  Widget renderWidget({VoidCallback onPressed}) => Error500Widget();
}

class Error400Exception implements MNewException{
  var message;
  Error400Exception(this.message);

  @override
  Widget renderWidget({VoidCallback onPressed}) => Error400Widget();
}

class NoInternetException implements MNewException{
  var message;
  NoInternetException(this.message);

  @override
  Widget renderWidget({VoidCallback onPressed}) => NoSignalWidget(onPressed: onPressed);
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
