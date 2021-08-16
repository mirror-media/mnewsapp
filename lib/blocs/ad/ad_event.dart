part of 'ad_bloc.dart';

@immutable
abstract class AdEvent {
  const AdEvent();
}

class LoadBannerAd extends AdEvent {
  late final AnchoredAdaptiveBannerAdSize? size;

  LoadBannerAd(this.size);


}
