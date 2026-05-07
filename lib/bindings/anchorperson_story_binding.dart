import 'package:get/get.dart';
import 'package:tv/controller/contact_detail_controller.dart';
import 'package:tv/services/contactService.dart';

class AnchorpersonStoryBinding extends Bindings {
  AnchorpersonStoryBinding(this.contactId);

  final String contactId;

  @override
  void dependencies() {
    if (!Get.isRegistered<ContactRepos>()) {
      Get.lazyPut<ContactRepos>(() => ContactServices());
    }

    if (!Get.isRegistered<ContactDetailController>(tag: contactId)) {
      Get.lazyPut<ContactDetailController>(
        () => ContactDetailController(
          contactId: contactId,
          contactRepos: Get.find<ContactRepos>(),
        ),
        tag: contactId,
      );
    }
  }
}
