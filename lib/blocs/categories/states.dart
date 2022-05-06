import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';

abstract class CategoriesState {}

class CategoriesInitState extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesLoaded extends CategoriesState {
  final List<Category> categoryList;
  CategoriesLoaded({required this.categoryList});
}

class VideoCategoriesLoaded extends CategoriesState {
  final List<Category> categoryList;
  final bool hasEditorChoice;
  final bool hasPopular;
  VideoCategoriesLoaded({
    required this.categoryList,
    this.hasEditorChoice = true,
    this.hasPopular = true,
  });
}

class CategoriesError extends CategoriesState {
  final MNewException? error;
  CategoriesError({this.error});
}
