import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/services/topicService.dart';

class TopicListController extends GetxController {
  TopicListController({required this.topicService});

  final TopicService topicService;

  final RxList<Topic> topicList = <Topic>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchTopicList();
  }

  Future<void> fetchTopicList() async {
    isLoading.value = true;
    error.value = null;

    try {
      final topics = await topicService.fetchTopicList();
      topicList.assignAll(topics);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
