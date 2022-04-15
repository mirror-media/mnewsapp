import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/programListItem.dart';

abstract class ProgramListRepos {
  Future<List<ProgramListItem>> fetchProgramList();
}

class ProgramListServices implements ProgramListRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<ProgramListItem>> fetchProgramList() async {
    final jsonResponse = await _helper.getByUrl(
        Environment().config.programListUrl,
        headers: {"Accept": "application/json"},
        skipCheck: true);

    List<ProgramListItem> programList;
    try {
      programList = List<ProgramListItem>.from(jsonResponse
          .map((programListItem) => ProgramListItem.fromJson(programListItem)));
      programList.sort((ProgramListItem a, ProgramListItem b) {
        int compare = a.year.compareTo(b.year);
        if (compare != 0) return compare;
        compare = a.month.compareTo(b.month);
        if (compare != 0) return compare;
        compare = a.day.compareTo(b.day);
        if (compare != 0) return compare;
        compare = a.startTimeHour.compareTo(b.startTimeHour);
        if (compare != 0) return compare;
        return a.startTimeMinute.compareTo(b.startTimeMinute);
      });
    } catch (e) {
      throw FormatException(e.toString());
    }
    return programList;
  }
}
