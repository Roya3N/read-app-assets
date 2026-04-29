import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCorrect() async {
    await _player.play(AssetSource('sounds/correct.mp3'));
  }

  static Future<void> playWrong() async {
    await _player.play(AssetSource('sounds/wrong.mp3'));
  }

  static Future<void> playReward() async {
    await _player.play(AssetSource('sounds/reward.mp3'));
  }
}