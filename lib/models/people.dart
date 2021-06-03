class People {
  String slug;
  String name;

  People({
    required this.slug,
    required this.name,
  });

  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      slug: json['slug'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'name': name,
      };
}
