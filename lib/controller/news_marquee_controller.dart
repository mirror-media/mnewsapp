import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/newsMarqueeService.dart';

class NewsMarqueeController extends GetxController {
  NewsMarqueeController({
    required this.newsMarqueeService,
  });

  final NewsMarqueeServices newsMarqueeService;

  final RxList<StoryListItem> newsList = <StoryListItem>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchNewsList();
  }

  Future<void> fetchNewsList() async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await newsMarqueeService.fetchNewsList();
      newsList.assignAll(response);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
