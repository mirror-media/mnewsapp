// event, state => new state => update UI.

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/services/categoryService.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';

class CategoriesBloc extends Bloc<CategoriesEvents, CategoriesState> {
  final CategoryRepos categoryRepos;

  CategoriesBloc({required this.categoryRepos}) : super(CategoriesInitState());

  Stream<CategoriesState> mapEventToState(CategoriesEvents event) async* {
    print(event.toString());
    try {
      yield CategoriesLoading();
      if (event is FetchCategories) {
        List<Category> categoryList = await categoryRepos.fetchCategoryList();
        yield CategoriesLoaded(categoryList: categoryList);
      } else if (event is FetchVideoCategories) {
        bool hasEditorChoice = true;
        bool hasPopular = true;
        List<Category> categoryList = [];
        await Future.wait([
          categoryRepos
              .fetchCategoryList()
              .then((value) => categoryList = value),
          EditorChoiceServices()
              .fetchVideoEditorChoiceList()
              .then((value) => hasEditorChoice = value.isNotEmpty),
          TabStoryListServices(postStyle: 'videoNews')
              .fetchPopularStoryList()
              .then((value) => hasPopular = value.isNotEmpty),
        ]);

        yield VideoCategoriesLoaded(
          categoryList: categoryList,
          hasEditorChoice: hasEditorChoice,
          hasPopular: hasPopular,
        );
      }
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
