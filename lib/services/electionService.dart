import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/election/municipality.dart';

abstract class ElectionRepos {
  Future<Map<String, dynamic>> fetchMunicipalityData(String jsonApi);
}

class ElectionService implements ElectionRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<Map<String, dynamic>> fetchMunicipalityData(String jsonApi) async {
    var jsonResponse = await _helper.getByCacheAndAutoCache(
      jsonApi,
      maxAge: const Duration(minutes: 2),
    );

    List<Municipality> municipalityList = [];
    for (var item in jsonResponse['polling']) {
      municipalityList.add(Municipality.fromJson(item));
    }

    return {
      'lastUpdateTime': DateTime.parse(jsonResponse['updatedAt']),
      'municipalityList': municipalityList,
    };
  }
}
