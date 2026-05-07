import 'package:get/get.dart';
import 'package:tv/controller/contact_list_controller.dart';
import 'package:tv/services/contactService.dart';

class AnchorpersonBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ContactRepos>()) {
      Get.lazyPut<ContactRepos>(() => ContactServices());
    }

    if (!Get.isRegistered<ContactListController>()) {
      Get.lazyPut<ContactListController>(
        () => ContactListController(contactRepos: Get.find<ContactRepos>()),
      );
    }
  }
}
