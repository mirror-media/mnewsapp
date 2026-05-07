import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/category.dart';
import 'package:tv/services/showService.dart';

class ShowCategoryController extends GetxController {
  ShowCategoryController({
    required this.showService,
  });

  final ShowServices showService;

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
      final response = await showService.fetchCategoryList();
      categoryList.assignAll(response);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
