import 'package:tv/models/anchorperson.dart';
import 'package:tv/models/anchorpersonList.dart';

abstract class AnchorpersonState {}

class AnchorpersonInitState extends AnchorpersonState {}

class AnchorpersonLoading extends AnchorpersonState {}

class AnchorpersonListLoaded extends AnchorpersonState {
  final AnchorpersonList anchorpersonList;
  AnchorpersonListLoaded({this.anchorpersonList});
}

class AnchorpersonLoaded extends AnchorpersonState {
  final Anchorperson anchorperson;
  AnchorpersonLoaded({this.anchorperson});
}

class AnchorpersonError extends AnchorpersonState {
  final error;
  AnchorpersonError({this.error});
}
