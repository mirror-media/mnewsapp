import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tv/models/election/municipality.dart';
import 'package:tv/services/electionService.dart';

part 'election_state.dart';

class ElectionCubit extends Cubit<ElectionState> {
  final ElectionRepos repos;
  final String jsonApi;
  ElectionCubit({required this.repos, required this.jsonApi})
      : super(ElectionInitial());

  void fetchMunicipalityData() async {
    if (jsonApi.isNotEmpty) {
      emit(UpdatingElectionData());
      try {
        var result = await repos.fetchMunicipalityData(jsonApi);
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

  void hideElectionBlock() {
    emit(HideElectionBlock());
  }
}
