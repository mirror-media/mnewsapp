abstract class CategoriesEvents {}

class FetchCategories extends CategoriesEvents {
  @override
  String toString() {
    return 'Fetch Categories';
  }
}

class FetchVideoCategories extends CategoriesEvents {
  @override
  String toString() {
    return 'Fetch Video Categories';
  }
}
