import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/categories/events.dart';
import 'package:tv/blocs/categories/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/category.dart';
import 'package:tv/services/categoryService.dart';
import 'package:tv/services/editorChoiceService.dart';
import 'package:tv/services/tabStoryListService.dart';

class CategoriesBloc extends Bloc<CategoriesEvents, CategoriesState> {
  final CategoryRepos categoryRepos;

  CategoriesBloc({required this.categoryRepos}) : super(CategoriesInitState()) {
    on<CategoriesEvents>((event, emit) async {
      print(event.toString());
      try {
        emit(CategoriesLoading());
        if (event is FetchCategories) {
          List<Category> categoryList = await categoryRepos.fetchCategoryList();
          emit(CategoriesLoaded(categoryList: categoryList));
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

          emit(VideoCategoriesLoaded(
            categoryList: categoryList,
            hasEditorChoice: hasEditorChoice,
            hasPopular: hasPopular,
          ));
        }
      } catch (e) {
        emit(CategoriesError(error: determineException(e)));
      }
    });
  }
}
