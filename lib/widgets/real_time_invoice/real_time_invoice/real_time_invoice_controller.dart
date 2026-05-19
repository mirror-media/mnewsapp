import 'dart:async';
import 'package:get/get.dart';
import '../data/provider/election_data_provider.dart';
import '../model/election_data.dart';

class RealTimeInvoiceController extends GetxController {
  final ElectionDataProvider electionDataProvider = Get.find();
  final Rxn<ElectionData> rxElectionData = Rxn();
  Timer? fetchDataTimer;

  final RxnInt rxCurrentSelect = RxnInt();

  @override
  void onInit() async {
    super.onInit();
    fetchElectionData();
    fetchDataTimer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      fetchElectionData();
    });
  }

  void fetchElectionData() async {
    rxElectionData.value = await electionDataProvider.getElectionData();
    final listData = rxElectionData.value?.electionRowDataList;
    if (listData == null) return;
    for (var data in listData) {
      if (data.key == '當選') {
        for (int valueIndex = 0;
            valueIndex < data.valueList.length;
            valueIndex++) {
          if (data.valueList[valueIndex] == '*') {
            rxCurrentSelect.value = valueIndex;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    fetchDataTimer?.cancel();
  }
}
