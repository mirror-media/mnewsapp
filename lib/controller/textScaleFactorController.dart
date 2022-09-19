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
      time: 1.seconds,
    );
    super.onInit();
  }

  void init() async {
    _prefs = await SharedPreferences.getInstance();
    textScaleFactor.value = _prefs.getDouble('textScaleFactor') ?? 1.0;
    //migrate from old version
    if (textScaleFactor.value == 1.2) {
      textScaleFactor.value = 1.7;
    }
  }
}
