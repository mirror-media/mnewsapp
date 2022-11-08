part of 'election_cubit.dart';

abstract class ElectionState extends Equatable {
  const ElectionState();

  @override
  List<Object> get props => [];
}

class ElectionInitial extends ElectionState {}

class UpdatingElectionData extends ElectionState {}

class ElectionDataLoaded extends ElectionState {
  final List<Municipality> municipalityList;
  final DateTime lastUpdateTime;
  const ElectionDataLoaded(
      {required this.municipalityList, required this.lastUpdateTime});
}

class HideElectionBlock extends ElectionState {}

class ElectionDataError extends ElectionState {}
