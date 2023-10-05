import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:tv/provider/airticles_api_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ArticlesApiProvider.instance);
  }
}
