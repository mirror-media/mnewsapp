import 'package:tv/models/showIntro.dart';

abstract class ShowState {}

class ShowInitState extends ShowState {}

class ShowLoading extends ShowState {}

class ShowIntroLoaded extends ShowState {
  final ShowIntro showIntro;
  ShowIntroLoaded({required this.showIntro});
}

class ShowError extends ShowState {
  final error;
  ShowError({this.error});
}
