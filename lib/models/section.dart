import 'package:tv/helpers/dataConstants.dart';

class Section {
  static const idKey = 'id';
  static const nameKey = 'name';

  final MNewsSection id;
  final String name;

  Section({
    this.id,
    this.name
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json[idKey],
      name: json[nameKey],
    );
  }
}