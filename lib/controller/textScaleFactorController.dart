import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextScaleFactorController extends GetxController {
  var textScaleFactor = 1.0.obs;
  late final SharedPreferences _prefs;

  @override
  void onInit() {
    init();
    debounce<double>(
      textScaleFactor,
      (_) async => await _prefs.setDouble('textScaleFactor', _),
    );
    super.onInit();
  }

  void init() async {
    _prefs = await SharedPreferences.getInstance();
    textScaleFactor.value = _prefs.getDouble('textScaleFactor') ?? 1.0;
  }
}
