import 'package:tv/models/customizedList.dart';
import 'package:tv/models/section.dart';

class SectionList extends CustomizedList<Section> {
  // constructor
  SectionList();

  factory SectionList.fromJson(List<dynamic> parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    SectionList sections = SectionList();
    List parseList = parsedJson.map((i) => Section.fromJson(i)).toList();
    parseList.forEach((element) {
      sections.add(element);
    });

    return sections;
  }
}
