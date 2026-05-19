import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/services/categoryService.dart';

class NewsCategoryController extends GetxController {
  NewsCategoryController({
    required this.categoryService,
  });

  final CategoryServices categoryService;

  final RxList<Category> categoryList = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await categoryService.fetchCategoryList();
      categoryList.assignAll(response);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
