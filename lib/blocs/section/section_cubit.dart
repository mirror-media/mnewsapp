import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/adUnitId.dart';

part 'section_state.dart';

class SectionCubit extends Cubit<SectionStateCubit> {
  SectionCubit() : super(SectionInitState());

  void changeSection(MNewsSection sectionId) async{
    print('ChangeSection { SectionId: $sectionId }');
    if(sectionId == MNewsSection.live){
      String jsonFixed = await rootBundle.loadString(adUnitIdJson);
      final fixedAdUnitId = json.decode(jsonFixed);
      AdUnitId adUnitId = AdUnitId.fromJson(fixedAdUnitId,'live');
      emit(SectionLoaded(sectionId: sectionId, adUnitId: adUnitId));
    }
    else{
      emit(SectionLoaded(sectionId: sectionId));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('SectionError: $error');
    super.onError(error, stackTrace);
    emit(SectionError(error: error));
  }
}
