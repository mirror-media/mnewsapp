part of 'video_cubit.dart';

@immutable
abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoaded extends VideoState {
  final Video? video;
  VideoLoaded({required this.video});
}

class VideoError extends VideoState {
  final error;
  VideoError({this.error});
}
