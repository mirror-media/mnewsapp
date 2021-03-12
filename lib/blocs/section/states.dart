import 'package:tv/models/mNewsSection.dart';

abstract class SectionState {
  final MNewsSection section;
  SectionState({this.section});
}

class SectionInitState extends SectionState {
  final MNewsSection section;
  SectionInitState({this.section = MNewsSection.news});
}

class SectionLoaded extends SectionState {
  final MNewsSection section;
  SectionLoaded({this.section = MNewsSection.news});
}

class SectionError extends SectionState {
  final error;
  SectionError({this.error});
}
