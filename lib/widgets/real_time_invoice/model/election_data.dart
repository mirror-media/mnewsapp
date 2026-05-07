import 'election_row_data.dart';

class ElectionData {
  String? title;
  List<ElectionRowData>? electionRowDataList;
  String? updateAt;

  ElectionData({this.title, this.electionRowDataList, this.updateAt});

  factory ElectionData.fromJson(Map<String, dynamic> json) {
    List<ElectionRowData> list = [];
    for (var resultItem in json['result']) {
      list.add(ElectionRowData.fromJson(resultItem));
    }
    return ElectionData(
        title: json['title'],
        electionRowDataList: list,
        updateAt: json['updateAt']);
  }
}
