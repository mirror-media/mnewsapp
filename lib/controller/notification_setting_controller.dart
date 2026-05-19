import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/notificationSetting.dart';
import 'package:tv/services/notificationSettingService.dart';

class NotificationSettingController extends GetxController {
  NotificationSettingController({
    required this.notificationSettingRepos,
  });

  final NotificationSettingRepos notificationSettingRepos;

  final RxList<NotificationSetting> notificationSettingList =
      <NotificationSetting>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchNotificationSettingList();
  }

  Future<void> fetchNotificationSettingList() async {
    isLoading.value = true;
    error.value = null;

    try {
      notificationSettingList.assignAll(
        await notificationSettingRepos.getNotificationSettingList(),
      );
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }

  void onExpansionChanged(int index, bool value) {
    final updatedList = notificationSettingRepos.onExpansionChanged(
      notificationSettingList,
      index,
      value,
    );
    notificationSettingList.assignAll(updatedList);
  }

  void onCheckBoxChanged(
    List<NotificationSetting> checkboxList,
    int index,
    bool isRepeatable,
  ) {
    final updatedList = notificationSettingRepos.onCheckBoxChanged(
      notificationSettingList,
      checkboxList,
      index,
      isRepeatable,
    );
    notificationSettingList.assignAll(updatedList);
  }
}
