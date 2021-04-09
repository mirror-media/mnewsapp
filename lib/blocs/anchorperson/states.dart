import 'package:tv/models/anchorpersonList.dart';

abstract class AnchorpersonState {}

class AnchorpersonInitState extends AnchorpersonState {}

class AnchorpersonLoading extends AnchorpersonState {}

class AnchorpersonListLoaded extends AnchorpersonState {
  final AnchorpersonList anchorpersonList;
  AnchorpersonListLoaded({this.anchorpersonList});
}

class AnchorpersonError extends AnchorpersonState {
  final error;
  AnchorpersonError({this.error});
}
