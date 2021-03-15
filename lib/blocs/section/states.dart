import 'package:tv/helpers/dataConstants.dart';

abstract class SectionState {
  final MNewsSection sectionId;
  SectionState({this.sectionId});
}

class SectionInitState extends SectionState {
  final MNewsSection sectionId;
  SectionInitState({this.sectionId = MNewsSection.news});
}

class SectionLoaded extends SectionState {
  final MNewsSection sectionId;
  SectionLoaded({this.sectionId});
}

class SectionError extends SectionState {
  final error;
  SectionError({this.error});
}
