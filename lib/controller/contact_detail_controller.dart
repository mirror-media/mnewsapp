import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/services/contactService.dart';

class ContactDetailController extends GetxController {
  ContactDetailController({
    required this.contactId,
    required this.contactRepos,
  });

  final String contactId;
  final ContactRepos contactRepos;

  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();
  final Rxn<Contact> contact = Rxn<Contact>();

  @override
  void onInit() {
    super.onInit();
    fetchContactById();
  }

  Future<void> fetchContactById() async {
    isLoading.value = true;
    error.value = null;

    try {
      contact.value = await contactRepos.fetchContactById(contactId);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
