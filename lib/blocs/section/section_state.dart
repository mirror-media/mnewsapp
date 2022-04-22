part of 'section_cubit.dart';

abstract class SectionStateCubit {
  final MNewsSection sectionId;

  SectionStateCubit({required this.sectionId});
}

class SectionInitState extends SectionStateCubit {
  SectionInitState({sectionId = MNewsSection.news})
      : super(sectionId: sectionId);
}

class SectionLoaded extends SectionStateCubit {
  SectionLoaded({required sectionId}) : super(sectionId: sectionId);
}

class SectionError extends SectionStateCubit {
  final error;
  SectionError({this.error}) : super(sectionId: MNewsSection.news);
}
