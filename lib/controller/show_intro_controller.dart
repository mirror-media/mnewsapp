import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/services/showService.dart';

class ShowIntroController extends GetxController {
  ShowIntroController({
    required this.showCategoryId,
    required this.showService,
  });

  final String showCategoryId;
  final ShowServices showService;

  final Rxn<ShowIntro> showIntro = Rxn<ShowIntro>();
  final RxBool isLoading = false.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  @override
  void onInit() {
    super.onInit();
    fetchShowIntro();
  }

  Future<void> fetchShowIntro() async {
    isLoading.value = true;
    error.value = null;

    try {
      showIntro.value = await showService.fetchShowIntroById(showCategoryId);
    } catch (e) {
      error.value = determineException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
