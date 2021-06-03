import 'package:tv/helpers/dataConstants.dart';

abstract class SectionState {
  final MNewsSection sectionId;
  SectionState({required this.sectionId});
}

class SectionInitState extends SectionState {
  SectionInitState({sectionId = MNewsSection.news}) : super(sectionId: sectionId);
}

class SectionLoaded extends SectionState {
  SectionLoaded({required sectionId}) : super(sectionId: sectionId);
}

class SectionError extends SectionState {
  final error;
  SectionError({this.error}) : super(sectionId: MNewsSection.news);
}
