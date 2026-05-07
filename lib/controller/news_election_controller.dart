import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/election/municipality.dart';
import 'package:tv/services/electionService.dart';

class NewsElectionController extends GetxController {
  NewsElectionController({
    required this.repos,
  });

  final ElectionRepos repos;
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  final RxList<Municipality> municipalityList = <Municipality>[].obs;
  final Rxn<DateTime> lastUpdateTime = Rxn<DateTime>();
  final RxBool isHidden = false.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentIndex = 0.obs;
  final Rxn<MNewException> error = Rxn<MNewException>();

  Timer? autoUpdateTimer;
  String api = '';
  String readmoreUrl = '';
  DateTime? startShowTime;
  DateTime? endShowTime;

  @override
  void onInit() {
    super.onInit();
    _initializeElectionConfig();
  }

  @override
  void onClose() {
    autoUpdateTimer?.cancel();
    super.onClose();
  }

  void _initializeElectionConfig() {
    final electionJsonString = remoteConfig.getString('election');

    try {
      final electionJson = jsonDecode(electionJsonString);
      api = electionJson['api'] ?? '';
      readmoreUrl = electionJson['readMoreUrl'] ?? '';
      startShowTime = DateTime.tryParse(electionJson['startTime'] ?? '');
      endShowTime = DateTime.tryParse(electionJson['endTime'] ?? '');

      if (api.isEmpty || startShowTime == null || endShowTime == null) {
        hideWidget();
        return;
      }

      updateElectionData();
      autoUpdateTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => updateElectionData(),
      );
    } catch (e) {
      error.value = determineException(e);
      hideWidget();
    }
  }

  Future<void> updateElectionData() async {
    final now = DateTime.now();
    if (endShowTime != null && now.isAfter(endShowTime!)) {
      hideWidget();
      autoUpdateTimer?.cancel();
      return;
    }

    if (startShowTime != null && now.isBefore(startShowTime!)) {
      hideWidget();
      return;
    }

    await fetchMunicipalityData();
  }

  Future<void> fetchMunicipalityData() async {
    isLoading.value = true;
    error.value = null;
    isHidden.value = false;

    try {
      final result = await repos.fetchMunicipalityData(api);
      lastUpdateTime.value = result['lastUpdateTime'] as DateTime?;
      municipalityList.assignAll(
        result['municipalityList'] as List<Municipality>,
      );

      if (municipalityList.isEmpty) {
        hideWidget();
      }
    } catch (e) {
      error.value = determineException(e);
      hideWidget();
    } finally {
      isLoading.value = false;
    }
  }

  void hideWidget() {
    isHidden.value = true;
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
