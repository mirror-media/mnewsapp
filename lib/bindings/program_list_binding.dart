import 'package:get/get.dart';
import 'package:tv/controller/program_list_controller.dart';
import 'package:tv/services/programListService.dart';

class ProgramListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgramListRepos>(() => ProgramListServices());
    Get.lazyPut<ProgramListController>(
      () => ProgramListController(programListRepos: Get.find<ProgramListRepos>()),
    );
  }
}
