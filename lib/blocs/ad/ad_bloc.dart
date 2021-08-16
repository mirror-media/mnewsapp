import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:meta/meta.dart';

part 'ad_event.dart';
part 'ad_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  AdBloc() : super(AdInitial());

  @override
  Stream<AdState> mapEventToState(
    AdEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
