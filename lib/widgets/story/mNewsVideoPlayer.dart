import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MNewsVideoPlayer extends StatefulWidget {
  final String videourl;
  final bool autoPlay;
  final Duration? startAt;
  final bool looping;
  final double aspectRatio;
  final bool muted;

  const MNewsVideoPlayer({
    super.key,
    required this.videourl,
    required this.aspectRatio,
    this.autoPlay = false,
    this.startAt,
    this.muted = false,
    this.looping = false,
  });

  @override
  State<MNewsVideoPlayer> createState() => _MNewsVideoPlayerState();
}

class _MNewsVideoPlayerState extends State<MNewsVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  late final VideoPlayerController _videoCtrl;
  ChewieController? _chewieCtrl;

  bool _initOk = false;
  bool _isError = false;
  String? _errorText;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.videourl));
      await _videoCtrl.initialize();

      // 對齊 BetterPlayer 行為
      await _videoCtrl.setLooping(widget.looping);
      if (widget.muted) {
        await _videoCtrl.setVolume(0.0);
      }

      // 起始播放點
      if (widget.startAt != null) {
        await _videoCtrl.seekTo(widget.startAt!);
      }

      // Chewie 控制器（接近 BetterPlayer 的 UI/行為）
      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControlsOnInitialize: false, // 保持有「轉圈圈」的感覺
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true, // 對齊 overflowMenuPlaybackSpeed
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        // 你也可以自訂 placeholder，對齊 showPlaceholderUntilPlay
        placeholder: const Center(child: CircularProgressIndicator.adaptive()),
      );

      if (widget.autoPlay) {
        // Chewie 的 autoPlay 會呼叫 play()；這裡保險處理一下
        _videoCtrl.play();
      }

      setState(() => _initOk = true);
    } catch (e) {
      setState(() {
        _isError = true;
        _errorText = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isError) {
      // 對齊 BetterPlayer translations.generalDefaultError
      return _ErrorView(message: "無法播放影片");
    }

    if (!_initOk || _chewieCtrl == null) {
      // 初始化中 → 轉圈圈
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // 注意：外層用傳入的 aspectRatio，避免 16:9 寫死的拉伸/黑邊問題
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Chewie(controller: _chewieCtrl!),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
