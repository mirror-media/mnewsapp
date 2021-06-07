import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/baseModel.dart';

class Section {
  final MNewsSection id;
  final String name;

  Section({
    required this.id,
    required this.name
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
    );
  }
}