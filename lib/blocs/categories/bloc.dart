// event, state => new state => update UI.

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/categoryList.dart';
import 'package:tv/services/categoryService.dart';

class CategoriesBloc extends Bloc<CategoryEvents, CategoriesState> {
  final CategoryRepos categoryRepos;
  CategoryList categoryList;

  CategoriesBloc({this.categoryRepos}) : super(CategoriesInitState());

  @override
  Stream<CategoriesState> mapEventToState(CategoryEvents event) async* {
    switch (event) {
      case CategoryEvents.fetchCategories:
        yield CategoriesLoading();
        try {
          categoryList = await categoryRepos.fetchCategoryList();
          yield CategoriesLoaded(categoryList: categoryList);
        } on SocketException {
          yield CategoriesError(
            error: NoInternetException('No Internet'),
          );
        } on HttpException {
          yield CategoriesError(
            error: NoServiceFoundException('No Service Found'),
          );
        } on FormatException {
          yield CategoriesError(
            error: InvalidFormatException('Invalid Response format'),
          );
        } catch (e) {
          yield CategoriesError(
            error: UnknownException(e.toString()),
          );
        }

        break;
    }
  }
}
