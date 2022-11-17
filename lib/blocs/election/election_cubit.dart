import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tv/models/election/municipality.dart';
import 'package:tv/services/electionService.dart';

part 'election_state.dart';

class ElectionCubit extends Cubit<ElectionState> {
  final ElectionRepos repos;
  ElectionCubit({required this.repos}) : super(ElectionInitial());

  void fetchMunicipalityData(String api) async {
    emit(UpdatingElectionData());
    try {
      var result = await repos.fetchMunicipalityData(api);
      emit(ElectionDataLoaded(
        lastUpdateTime: result['lastUpdateTime'],
        municipalityList: result['municipalityList'],
      ));
    } catch (e) {
      print('Fetch election data failed: $e');
      emit(ElectionDataError());
    }
  }
}
