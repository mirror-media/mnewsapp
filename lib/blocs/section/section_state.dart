part of 'section_cubit.dart';

abstract class SectionStateCubit {
  final MNewsSection sectionId;
  final AdUnitId? adUnitId;
  SectionStateCubit({required this.sectionId,this.adUnitId});
}

class SectionInitState extends SectionStateCubit {
  SectionInitState({sectionId = MNewsSection.news}) : super(sectionId: sectionId);
}

class SectionLoaded extends SectionStateCubit {
  SectionLoaded({required sectionId, adUnitId}) : super(sectionId: sectionId, adUnitId: adUnitId);
}

class SectionError extends SectionStateCubit {
  final error;
  SectionError({this.error}) : super(sectionId: MNewsSection.news);
}
