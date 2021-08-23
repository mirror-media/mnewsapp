import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/categoryList.dart';

abstract class CategoriesState {}

class CategoriesInitState extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final CategoryList categoryList;
  final List<BannerAd> bannerAdList;
  CategoriesLoaded({required this.categoryList, required this.bannerAdList});
}

class CategoriesError extends CategoriesState {
  final MNewException? error;
  CategoriesError({this.error});
}
