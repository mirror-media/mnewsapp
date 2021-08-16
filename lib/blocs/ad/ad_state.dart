part of 'ad_bloc.dart';

@immutable
abstract class AdState {}

class AdInitial extends AdState {}

class BannerAdLoaded extends AdState {}

class NativeAdLoaded extends AdState {}

class InterstitalAdLoaded extends AdState {}

class AdLoading extends AdState {}

class AdLoadFailed extends AdState {}
