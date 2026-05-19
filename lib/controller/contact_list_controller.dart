import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/services/contactService.dart';

class ContactListController extends GetxController {
  ContactListController({required this.contactRepos});

  final ContactRepos contactRepos;

  final RxList<Contact> contactList = <Contact>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  List<Contact> get anchorpersonContactList =>
      contactList.where((contact) => contact.isAnchorperson).toList();

  List<Contact> get hostContactList =>
      contactList.where((contact) => contact.isHost).toList();

  @override
  void onInit() {
    super.onInit();
    fetchAnchorpersonOrHostContactList();
  }

  Future<void> fetchAnchorpersonOrHostContactList() async {
    isLoading.value = true;
    error.value = null;

    try {
      final contacts = await contactRepos.fetchAnchorpersonOrHostContactList();
      contactList.assignAll(contacts);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
