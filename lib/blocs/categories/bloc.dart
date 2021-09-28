// event, state => new state => update UI.

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/categoryList.dart';
import 'package:tv/services/categoryService.dart';

class CategoriesBloc extends Bloc<CategoriesEvents, CategoriesState> {
  final CategoryRepos categoryRepos;
  CategoryList categoryList = CategoryList();

  CategoriesBloc({required this.categoryRepos}) : super(CategoriesInitState());

  @override
  Stream<CategoriesState> mapEventToState(CategoriesEvents event) async* {
    if (event is FetchCategories) {
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
      } on FetchDataException {
        yield CategoriesError(
          error: NoInternetException('Error During Communication'),
        );
      } on BadRequestException {
        yield CategoriesError(
          error: Error400Exception('Invalid Request'),
        );
      } on UnauthorisedException {
        yield CategoriesError(
          error: Error400Exception('Unauthorised'),
        );
      } on InvalidInputException {
        yield CategoriesError(
          error: Error400Exception('Invalid Input'),
        );
      } on InternalServerErrorException {
        yield CategoriesError(
          error: Error500Exception('Internal Server Error'),
        );
      } catch (e) {
        yield CategoriesError(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
