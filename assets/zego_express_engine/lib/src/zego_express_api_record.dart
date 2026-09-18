import 'zego_express_api.dart';
import 'impl/zego_express_impl.dart';
import 'zego_express_defines.dart';

// ignore_for_file: deprecated_member_use_from_same_package

extension ZegoExpressEngineRecord on ZegoExpressEngine {
  /// Starts to record and directly save the data to a file.
  ///
  /// Available since: 1.10.0
  /// Description: Starts to record locally captured audio or video and directly save the data to a file, The recorded data will be the same as the data publishing through the specified channel.
  /// Restrictions: None.
  /// Caution: Developers should not [stopPreview] or [stopPublishingStream] during recording, otherwise the SDK will end the current recording task. The data of the media player needs to be mixed into the publishing stream to be recorded.
  /// Related callbacks: Developers will receive the [onCapturedDataRecordStateUpdate] and the [onCapturedDataRecordProgressUpdate] callback after start recording.
  ///
  /// - [config] Record config.
  /// - [channel] Publishing stream channel.
  Future<void> startRecordingCapturedData(ZegoDataRecordConfig config,
      {ZegoPublishChannel? channel}) async {
    return await ZegoExpressImpl.instance
        .startRecordingCapturedData(config, channel: channel);
  }

  /// Stops recording locally captured audio or video.
  ///
  /// Available since: 1.10.0
  /// Description: Stops recording locally captured audio or video.
  /// When to call: After [startRecordingCapturedData].
  /// Restrictions: None.
  ///
  /// - [channel] Publishing stream channel.
  Future<void> stopRecordingCapturedData({ZegoPublishChannel? channel}) async {
    return await ZegoExpressImpl.instance
        .stopRecordingCapturedData(channel: channel);
  }

  /// Starts to record and directly save the data to a file.
  ///
  /// Available since: 3.21.0
  /// Description: Start remote streaming recording and save the audio-video data directly to local files. The recorded data will be identical to the streamed data.
  /// Restrictions: None.
  /// Caution: Developers should not [stopPlayingStream] during recording, otherwise the SDK will end the current recording task. The data of the media player needs to be mixed into the publishing stream to be recorded.
  /// Related callbacks: Developers will receive the [onRemoteDataRecordStateUpdate] and the [onRemoteDataRecordProgressUpdate] callback after start recording.
  ///
  /// - [config] Record config.
  /// - [streamID] play stream id.
  Future<void> startRecordingRemoteData(
      ZegoDataRecordConfig config, String streamID) async {
    return await ZegoExpressImpl.instance
        .startRecordingRemoteData(config, streamID);
  }

  /// Stops recording locally captured audio or video.
  ///
  /// Available since: 3.21.0
  /// Description: Stops remote recording audio or video.
  /// When to call: After [startRecordingRemoteData].
  /// Restrictions: None.
  ///
  /// - [streamID] play stream id.
  Future<void> stopRecordingRemoteData(String streamID) async {
    return await ZegoExpressImpl.instance.stopRecordingRemoteData(streamID);
  }
}
