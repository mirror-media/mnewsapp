import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/programListItem.dart';
import 'package:tv/services/programListService.dart';

class ProgramListController extends GetxController {
  ProgramListController({required this.programListRepos});

  final ProgramListRepos programListRepos;

  final RxList<ProgramListItem> programList = <ProgramListItem>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString buttonText = '請選擇日期'.obs;
  final RxBool isDefaultDate = true.obs;

  bool get isInitState => isLoading.value && programList.isEmpty && error.value == null;

  @override
  void onInit() {
    super.onInit();
    fetchProgramList();
  }

  Future<void> fetchProgramList() async {
    isLoading.value = true;
    error.value = null;

    try {
      final items = await programListRepos.fetchProgramList();
      programList.assignAll(items);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
    isDefaultDate.value = false;
    buttonText.value = '${date.year}年${date.month}月${date.day}日';
  }
}
