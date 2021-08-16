import 'package:tv/models/baseModel.dart';

class Category {
  String? id;
  String name;
  String? slug;
  bool? isFeatured;
  int? sortOrder;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.isFeatured,
    required this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
      isFeatured: json['isFeatured'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
        BaseModel.slugKey: slug,
      };

  bool isLatestCategory() {
    return id == 'latest';
  }

  bool isFeaturedCategory() {
    return id == 'featured';
  }

  static bool checkIsLatestCategoryBySlug(String? slug) {
    return slug == 'latest';
  }

  @override
  int get hashCode => this.hashCode;

  @override
  bool operator ==(covariant Category other) {
    // compare this to other
    return this.id == other.id;
  }
}
