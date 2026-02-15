import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:tableronde_app/models/chat_model.dart';
import 'package:tableronde_app/utils/theme_extensions.dart';

class VoiceMessage extends StatefulWidget {
  final MessageModel message;

  const VoiceMessage({super.key, required this.message});

  @override
  State<VoiceMessage> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      String? url = widget.message.attachmentUrl; // Local path from recording
      // or widget.message.voiceUrl if it was a remote URL

      if (url != null && url.isNotEmpty) {
        // If it's a local file (starts with /), use DeviceFileSource
        if (url.startsWith('/')) {
          await _audioPlayer.play(DeviceFileSource(url));
        } else {
          await _audioPlayer.play(UrlSource(url));
        }
      }
    }
  }

  String _formatNumber(int number) {
    if (number < 10) {
      return '0$number';
    }
    return number.toString();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${_formatNumber(minutes)}:${_formatNumber(remainingSeconds)}';
  }

  @override
  Widget build(BuildContext context) {
    // Determine max duration: either from metadata or actual audio file if loaded
    final durationSec = widget.message.voiceDuration ?? 0;
    final maxDuration = _duration.inSeconds > 0
        ? _duration.inSeconds.toDouble()
        : durationSec.toDouble();
    final currentPos = _position.inSeconds.toDouble();

    // Clamp value to avoid assertions
    final sliderValue =
        currentPos.clamp(0.0, maxDuration > 0 ? maxDuration : 1.0);
    final sliderMax = maxDuration > 0 ? maxDuration : 1.0;

    // Use theme colors for text/icons on the message bubble
    // Since message bubbles have a solid background color (sent/received),
    // the content should use textPrimary color for contrast in both light (dark text on light bubble)
    // and dark (light text on dark bubble) themes.
    final foregroundColor = context.themeColors.textPrimary;

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: foregroundColor,
              size: 30,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: foregroundColor,
                    inactiveTrackColor: foregroundColor.withOpacity(0.3),
                    thumbColor: foregroundColor,
                    overlayColor: foregroundColor.withOpacity(0.1),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0.0,
                    max: sliderMax,
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    _formatDuration(_position.inSeconds > 0
                        ? _position.inSeconds
                        : durationSec),
                    style: TextStyle(
                      fontSize: 11,
                      color: foregroundColor.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.mic,
            color: foregroundColor.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }
}
