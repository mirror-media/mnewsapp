import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/models/showIntro.dart';

abstract class ShowState {}

class ShowInitState extends ShowState {}

class ShowLoading extends ShowState {}

class ShowIntroLoaded extends ShowState {
  final ShowIntro showIntro;
  final List<BannerAd> bannerAdList;
  ShowIntroLoaded({required this.showIntro, required this.bannerAdList});
}

class ShowError extends ShowState {
  final error;
  ShowError({this.error});
}
