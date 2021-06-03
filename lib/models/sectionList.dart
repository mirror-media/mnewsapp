import 'package:tv/models/customizedList.dart';
import 'package:tv/models/section.dart';

class SectionList extends CustomizedList<Section> {
  // constructor
  SectionList();

  factory SectionList.fromJson(List<dynamic> parsedJson) {
    SectionList sections = SectionList();
    List parseList = parsedJson.map((i) => Section.fromJson(i)).toList();
    parseList.forEach((element) {
      sections.add(element);
    });

    return sections;
  }
}
