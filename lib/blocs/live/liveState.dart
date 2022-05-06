part of 'liveCubit.dart';

@immutable
abstract class LiveState {}

class LiveInitial extends LiveState {}

class LiveIdLoaded extends LiveState {
  final String liveId;
  LiveIdLoaded({required this.liveId});
}

class LiveIdListLoaded extends LiveState {
  final List<LiveCamItem> liveCamList;
  LiveIdListLoaded({required this.liveCamList});
}

class LiveError extends LiveState {
  final error;
  LiveError({this.error});
}
