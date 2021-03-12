class Section {
  final String id;
  final String name;

  Section({
    this.id,
    this.name
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
    );
  }
}