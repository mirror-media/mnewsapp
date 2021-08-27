import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/showIntro.dart';

abstract class ShowState {}

class ShowInitState extends ShowState {}

class ShowLoading extends ShowState {}

class ShowIntroLoaded extends ShowState {
  final ShowIntro showIntro;
  final AdUnitId adUnitId;
  ShowIntroLoaded({required this.showIntro, required this.adUnitId});
}

class ShowError extends ShowState {
  final error;
  ShowError({this.error});
}
