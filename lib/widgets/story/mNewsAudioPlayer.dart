import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tv/helpers/dateTimeFormat.dart';

class MNewsAudioPlayer extends StatefulWidget {
  /// The baseUrl of the audio
  final String audioUrl;

  /// The title of audio
  final String title;

  /// The description of audio
  final String description;
  MNewsAudioPlayer({
    @required this.audioUrl,
    this.title,
    this.description,
  });

  @override
  _MNewsAudioPlayerState createState() => _MNewsAudioPlayerState();
}

class _MNewsAudioPlayerState extends State<MNewsAudioPlayer> with AutomaticKeepAliveClientMixin {
  Color _audioColor = Color(0xff014DB8);
  AudioPlayer _audioPlayer;
  bool get _checkIsPlaying => !(_audioPlayer.state == null ||
      _audioPlayer.state == AudioPlayerState.COMPLETED ||
      _audioPlayer.state == AudioPlayerState.STOPPED ||
      _audioPlayer.state == AudioPlayerState.PAUSED);
  int _duration = 0;

  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    _initAudioPlayer();
    super.initState();
  }

  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(widget.audioUrl);
  }

  _start() async {
    try {
      _duration = await _audioPlayer.getDuration();
      if(_duration < 0) {
        _duration = 0;
      }
    } catch(e) {
      _duration = 0;
    }
    
    await _audioPlayer.play(widget.audioUrl);
  }

  _play() async {
    await _audioPlayer.resume();
  }

  _pause() async {
    await _audioPlayer.pause();
  }

  _playAndPause() {
    if (_audioPlayer.state == null ||
        _audioPlayer.state == AudioPlayerState.COMPLETED ||
        _audioPlayer.state == AudioPlayerState.STOPPED) {
      _start();
    } else if (_audioPlayer.state == AudioPlayerState.PLAYING) {
      _pause();
    } else if (_audioPlayer.state == AudioPlayerState.PAUSED) {
      _play();
    }
  }

  @override
  void dispose() {
    if (_audioPlayer.state != null) {
      _audioPlayer.release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    
    super.build(context);
    return Card(
      elevation: 10,
      color: Color(0xffD8EAEB),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _audioColor,
              ),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                StreamBuilder<AudioPlayerState>(
                    stream: _audioPlayer.onPlayerStateChanged,
                    builder: (context, snapshot) {
                      return InkWell(
                        child: _checkIsPlaying
                            ? ClipOval(
                                child: Material(
                                  color: Color(0xff003366),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.pause,
                                      color: Color(0xffFFCC00),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                            : ClipOval(
                                child: Material(
                                  color: Color(0xff003366),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Color(0xffFFCC00),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                        onTap: () {
                          _playAndPause();
                        },
                      );
                    }),
                Expanded(
                  child: StreamBuilder<Duration>(
                      stream: _audioPlayer.onAudioPositionChanged,
                      builder: (context, snapshot) {
                        double sliderPosition = snapshot.data == null
                            ? 0.0
                            : snapshot.data.inMilliseconds.toDouble();
                        String position =
                            DateTimeFormat.stringDuration(snapshot.data);
                        String duration = DateTimeFormat.stringDuration(
                            Duration(milliseconds: _duration));
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _duration == 0
                            ? Slider(
                                value: 0,
                                onChanged: (v){},
                              )
                            : Slider(
                                min: 0.0,
                                max: _duration.toDouble(),
                                value: sliderPosition,
                                activeColor: _audioColor,
                                inactiveColor: Color(0xff979797),
                                onChanged: (v) {
                                  if (_audioPlayer.state != null) {
                                    _audioPlayer
                                        .seek(Duration(milliseconds: v.toInt()));
                                  }
                                },
                              ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 24.0, left: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    position,
                                    style: TextStyle(
                                      color: _audioColor,
                                    ),
                                  ),
                                  Text(
                                    duration,
                                    style: TextStyle(
                                      color: _audioColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
