part of 'program_list_cubit.dart';

@immutable
abstract class ProgramListState {}

class ProgramListInitial extends ProgramListState {}

class ProgramListLoaded extends ProgramListState {
  final List<ProgramListItem> programList;
  ProgramListLoaded({required this.programList});
}

class ProgramListError extends ProgramListState {
  final error;
  ProgramListError({this.error});
}
