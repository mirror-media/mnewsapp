abstract class SectionState {
  final String sectionId;
  SectionState({this.sectionId});
}

class SectionInitState extends SectionState {
  final String sectionId;
  SectionInitState({this.sectionId = 'news'});
}

class SectionLoaded extends SectionState {
  final String sectionId;
  SectionLoaded({this.sectionId});
}

class SectionError extends SectionState {
  final error;
  SectionError({this.error});
}
