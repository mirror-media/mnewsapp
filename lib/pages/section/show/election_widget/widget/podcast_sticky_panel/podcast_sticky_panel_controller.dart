import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:tv/core/enum/playback_status.dart';
import 'package:tv/core/enum/podcast_panel_status.dart';
import 'package:tv/models/podcast_info/podcast_info.dart';
import 'package:tv/pages/section/show/election_widget/election_controller.dart';

class PodcastStickyPanelController extends GetxController {
  final RxDouble rxSlideBarValue = 0.0.obs;
  final Rxn<PodcastInfo> rxnPodcastInfo = Rxn();
  final Rx<PodcastPanelStatus> rxPodcastPanelStatus =
      Rx<PodcastPanelStatus>(PodcastPanelStatus.stop);

  AudioPlayer? audioPlayer;
  Worker? currentPodcastInfoWorker;
  final Rx<Duration> rxPosition = Rx<Duration>(const Duration());
  final Rx<Duration> rxDuration = Rx<Duration>(const Duration());

  final RxBool rxIsPlay = false.obs;
  final RxBool rxIsMute = false.obs;
  final Rx<PlaybackStatus> rxPlaybackRate =
      Rx<PlaybackStatus>(PlaybackStatus.normalRate);
  late String? tag;

  PodcastStickyPanelController(String? _tag) {
    tag = _tag;
  }

  @override
  void onReady() {
    ElectionController electionController = Get.find(tag: tag);
    currentPodcastInfoWorker = ever<PodcastInfo?>(
        electionController.rxnSelectPodcastInfo, (podcastInfo) {
      rxnPodcastInfo.value = podcastInfo;
      if (rxnPodcastInfo.value != null) {
        playAudio(rxnPodcastInfo.value?.enclosures![0].url);
      } else {
        audioPlayer?.stop();
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    audioPlayer = AudioPlayer();
    audioPlayer?.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.stopped:
          rxPodcastPanelStatus.value = PodcastPanelStatus.stop;
          break;
        case PlayerState.playing:
          rxPodcastPanelStatus.value = PodcastPanelStatus.play;
          break;
        case PlayerState.paused:
          rxPodcastPanelStatus.value = PodcastPanelStatus.stop;
          break;
        case PlayerState.completed:
          rxPodcastPanelStatus.value = PodcastPanelStatus.stop;
          break;
      }
    });
    audioPlayer?.onPositionChanged.listen((pos) {
      rxPosition.value = pos;
    });
    audioPlayer?.onDurationChanged.listen((duration) {
      rxDuration.value = duration;
    });
  }

  void playAudio(String? source) async {
    if (source == null) {
      rxPodcastPanelStatus.value = PodcastPanelStatus.error;
      return;
    }

    await audioPlayer?.play(UrlSource(source));
  }

  void playButtonClick() {
    if (rxPodcastPanelStatus.value == PodcastPanelStatus.play) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.resume();
    }
  }

  void volumeButtonClick() {
    rxIsMute.value = !rxIsMute.value;
    if (rxIsMute.isTrue) {
      audioPlayer?.setVolume(0);
    } else {
      audioPlayer?.setVolume(1);
    }
  }

  void playbackRateButtonClick() {
    final preStatus = audioPlayer?.state;
    switch (rxPlaybackRate.value) {
      case PlaybackStatus.doubleRate:
        rxPlaybackRate.value = PlaybackStatus.normalRate;
        audioPlayer?.setPlaybackRate(1.0);
        if (preStatus == PlayerState.paused) {
          audioPlayer?.pause();
        }

        break;
      case PlaybackStatus.normalRate:
        rxPlaybackRate.value = PlaybackStatus.onePointFiveRate;
        audioPlayer?.setPlaybackRate(1.5);
        if (preStatus == PlayerState.paused) {
          audioPlayer?.pause();
        }
        break;
      case PlaybackStatus.onePointFiveRate:
        rxPlaybackRate.value = PlaybackStatus.doubleRate;
        audioPlayer?.setPlaybackRate(2.0);
        if (preStatus == PlayerState.paused) {
          audioPlayer?.pause();
        }
        break;
    }
  }

  void slideBarValueChangeEvent(double value) {
    rxSlideBarValue.value = value;
    Duration newDuration = Duration(seconds: value.toInt());
    audioPlayer?.seek(newDuration);
  }

  @override
  void dispose() {
    super.dispose();
    currentPodcastInfoWorker?.dispose();
    audioPlayer?.stop();
    audioPlayer?.dispose();
  }
}
