// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioUtil {
  final AudioPlayer audioPlayer = AudioPlayer();

  Uint8List _beepTickData = Uint8List(1);
  Uint8List _beep100CompleteData = Uint8List(1);
  Uint8List _beepFullCompletedData = Uint8List(1);

  Uint8List _speechTickData = Uint8List(1);
  Uint8List _speech100CompleteData = Uint8List(1);
  Uint8List _speechFullCompletedData = Uint8List(1);

  Uint8List _speechFastTickData = Uint8List(1);
  Uint8List _speechFast100CompleteData = Uint8List(1);

  Uint8List _silenceData = Uint8List(1);

  void loadAudio() async {
    // Load the Audio Data

    ByteData bytes = await rootBundle.load('assets/audio/beep.mp3');
    _beepTickData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/beep100Completed.mp3');
    _beep100CompleteData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/beepCompleted.mp3');
    _beepFullCompletedData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/speech.mp3');
    _speechTickData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/speech100Completed.mp3');
    _speech100CompleteData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/speechCompleted.mp3');
    _speechFullCompletedData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/speechFast.mp3');
    _speechFastTickData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/speechFast100Completed.mp3');
    _speechFast100CompleteData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    bytes = await rootBundle.load('assets/audio/silence.mp3');
    _silenceData =
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    audioPlayer.setReleaseMode(ReleaseMode.STOP);
  }

  Future<void> playTickAudio(bool isSpeech, bool isFast) async {
    isSpeech
        ? await audioPlayer
            .playBytes(isFast ? _speechFastTickData : _speechTickData)
        : await audioPlayer.playBytes(_beepTickData);
  }

  Future<void> play100CompleteAudio(bool isSpeech, bool isFast) async {
    isSpeech
        ? await audioPlayer.playBytes(
            isFast ? _speechFast100CompleteData : _speech100CompleteData)
        : await audioPlayer.playBytes(_beep100CompleteData);
  }

  Future<void> playTasbeehCompleteAudio(bool isSpeech) async {
    isSpeech
        ? await audioPlayer.playBytes(_speechFullCompletedData)
        : await audioPlayer.playBytes(_beepFullCompletedData);
  }

  void playSilenceAudio() {
    audioPlayer.playBytes(_silenceData);
  }
}
