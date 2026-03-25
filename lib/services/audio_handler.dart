// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:phone_state/phone_state.dart';

import 'package:tasbeeh/providers/data.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => TasbeehAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mujeeb.tasbeeh.audio',
      androidNotificationChannelName: 'Tasbeeh',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
    ),
  );
}

class TasbeehAudioHandler extends BaseAudioHandler {
  Data? data;
  Timer? tasbeehTickTimer;

  PhoneStateStatus status = PhoneStateStatus.NOTHING;
  bool isPausedDueToPhoneCall = false;

  void setStream() {
    PhoneState.stream.listen((event) {
        status = event.status;
    });
  }

  void setData(Data pData) {
    data = pData;
    setStream();
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (data!.isPlayPause &&
          !isPausedDueToPhoneCall &&
          (status == PhoneStateStatus.CALL_INCOMING ||
              status == PhoneStateStatus.CALL_STARTED)) {
        data!.togglePlayPause();
        isPausedDueToPhoneCall = true;
      }

      if (isPausedDueToPhoneCall &&
          !data!.isPlayPause &&
          (status == PhoneStateStatus.CALL_ENDED ||
              status == PhoneStateStatus.NOTHING)) {
        data!.togglePlayPause();
        isPausedDueToPhoneCall = false;
      }
    });

    // For Bluetooth Updating Song Information
    setCaptioningEnabled(true);

    handleButtonClick(pData.isPlayPause);
  }

  void udpateBluetoothMediaInfo(String message) {
    updateMediaItem(MediaItem(
        id: 'Smart Tasbeeh',
        title: 'Smart Tasbeeh',
        album: 'Quran',
        artist: 'Mujeeb Mohammad',
        displayTitle: 'Smart Tasbeeh',
        displaySubtitle: message,
        playable: true));
  }

  @override
  Future<void> play() async {
    await handleButtonClick(true);
  }

  @override
  Future<void> pause() async {
    await handleButtonClick(false);
  }

  @override
  Future<void> skipToNext() async {
    await handleButtonClick(true);
  }

  @override
  Future<void> skipToPrevious() async {
    await handleButtonClick(false);
  }

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> stop() async {
    await handleButtonClick(false);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    await handleButtonClick(!data!.isPlayPause);
  }

  Future<void> handleButtonClick(bool state) async {
    data!.changePlayPauseState(state);

    if (!data!.isPlayPause) {
      if (tasbeehTickTimer != null) {
        tasbeehTickTimer!.cancel();
      }
    }

    if (data!.isPlayPause) {
      tasbeehTickTimer =
          Timer(Duration(milliseconds: data!.tickDuration), handleTimer);
    }
  }

  void handleTimer() async {
    await data!.incrementTasbeeh();

    udpateBluetoothMediaInfo('Current: ' +
        data!.count.toString() +
        ', Target: ' +
        data!.targetCount.toString());

    if ((data!.is99Names && data!.currentNameIndex >= Data.Allah99Names.length) || (!data!.is99Names && data!.count >= data!.targetCount)) {
      data!.changePlayPauseState(false);
    }

    if (!data!.isPlayPause) {
      if (tasbeehTickTimer != null) {
        tasbeehTickTimer!.cancel();
      }
      return;
    }

    int autoPilotTickDelay = data!.tickDuration;
    if (data!.isAutoPilotOn) {
      if(data!.is99Names) {

        if(data!.currentNameIndex == 83 || data!.currentNameIndex == 84) {
          autoPilotTickDelay = (autoPilotTickDelay * Data.TICK_MULTIPLIER).toInt();
        }
      } else {
        autoPilotTickDelay =
            (autoPilotTickDelay - ((data!.minTickDuration / 50) * data!.count))
                .toInt();
        if (autoPilotTickDelay < data!.minTickDuration) {
          autoPilotTickDelay = data!.minTickDuration;
        }
      }
    }

    if (data!.isPlayPause) {
      tasbeehTickTimer =
          Timer(Duration(milliseconds: autoPilotTickDelay), handleTimer);
    }
  }
}
