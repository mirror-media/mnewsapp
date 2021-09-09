import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/models/programList.dart';

import '../baseConfig.dart';

abstract class ProgramListRepos {
  Future<ProgramList> fetchProgramList();
}

class ProgramListServices implements ProgramListRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<ProgramList> fetchProgramList() async {
    final jsonResponse = await _helper.getByUrl(baseConfig!.programListUrl,
        headers: {"Accept": "application/json"}, skipCheck: true);

    ProgramList programList;
    try {
      programList = ProgramList.fromJson(jsonResponse);
    } catch (e) {
      throw FormatException(e.toString());
    }
    return programList;
  }
}
