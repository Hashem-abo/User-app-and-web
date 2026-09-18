#ifndef ZEGO_CUSTOM_AUDIO_PROCESS_MANAGER_H_
#define ZEGO_CUSTOM_AUDIO_PROCESS_MANAGER_H_

#include "ZegoCustomVideoDefine.h"

class FLUTTER_PLUGIN_EXPORT IZegoFlutterCustomAudioProcessHandler {
protected:
    virtual ~IZegoFlutterCustomAudioProcessHandler() {}
public:
    /// Custom audio processing local captured PCM audio frame callback.
    ///
    /// Available: Since 2.13.0
    /// Description: In this callback, you can receive the PCM audio frames captured locally after used headphone monitor. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc. If you need the data after used headphone monitor, please use the [onProcessCapturedAudioDataAfterUsedHeadphoneMonitor] callback.
    /// When to trigger: You need to call [enableCustomAudioCaptureProcessing] to enable the function first, and call [startPreview] or [startPublishingStream] to trigger this callback function.
    /// Restrictions: None.
    /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
    ///
    /// @param data Audio data in PCM format.
    /// @param dataLength Length of the data.
    /// @param param Parameters of the audio frame.
    /// @param timestamp The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds.
    virtual void onProcessCapturedAudioData(unsigned char * /*data*/, unsigned int /*dataLength*/,
                                            ZGFlutterAudioFrameParam * /*param*/, double /*timestamp*/) {

    }

    /// Custom audio processing local captured PCM audio frame callback after used headphone monitor.
    ///
    /// Available: Since 2.13.0
    /// Description: In this callback, you can receive the PCM audio frames captured locally after used headphone monitor. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc.
    /// When to trigger: You need to call [enableCustomAudioCaptureProcessingAfterHeadphoneMonitor] to enable the function first, and call [startPreview] or [startPublishingStream] to trigger this callback function.
    /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
    ///
    /// @param data Audio data in PCM format
    /// @param dataLength Length of the data
    /// @param param Parameters of the audio frame
    /// @param timestamp The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds.
    virtual void onProcessCapturedAudioDataAfterUsedHeadphoneMonitor(
        unsigned char * /*data*/, unsigned int /*dataLength*/, ZGFlutterAudioFrameParam * /*param*/,
        double /*timestamp*/) {}

    /// Audio data callback before SDK internal audio preprocessing.
    ///
    /// Available: Since 3.11.0
    /// Description: In this callback, you can receive the audio data before SDK internal audio preprocessing.
    /// When to trigger: This callback function will not be triggered until [enableBeforeAudioPrepAudioData] is called to turn on the function and [startpublishingstream] is called.
    /// Restrictions: None.
    /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback, and the data in this callback cannot be modified.
    ///
    /// @param data Audio data in PCM format.
    /// @param dataLength Length of the data.
    /// @param param Parameters of the audio frame.
    virtual void onBeforeAudioPrepAudioData(unsigned char * /*data*/, unsigned int /*dataLength*/,
                                            ZGFlutterAudioFrameParam * /*param*/) {}

    /// Custom audio processing remote playing stream PCM audio frame callback.
    ///
    /// Available: Since 2.13.0
    /// Description: In this callback, you can receive the PCM audio frames of remote playing stream. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc.
    /// When to trigger: You need to call [enableCustomAudioRemoteProcessing] to enable the function first, and call [startPlayingStream] to trigger this callback function.
    /// Restrictions: None.
    /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
    ///
    /// @param data Audio data in PCM format.
    /// @param dataLength Length of the data.
    /// @param param Parameters of the audio frame.
    /// @param streamID Corresponding stream ID.
    /// @param timestamp The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds.
    virtual void onProcessRemoteAudioData(unsigned char * /*data*/, unsigned int /*dataLength*/,
                                          ZGFlutterAudioFrameParam * /*param*/,
                                          const std::string & /*streamID*/, double /*timestamp*/) {}

    /// Custom audio processing SDK playback PCM audio frame callback.
    ///
    /// Available: Since 2.13.0
    /// Description: In this callback, you can receive the SDK playback PCM audio frame. Developers can modify the audio frame data, as well as the audio channels and sample rate. The timestamp can be used for data synchronization, such as lyrics, etc.
    /// When to trigger: You need to call [enableCustomAudioPlaybackProcessing] to enable the function first, and call [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] or [createAudioEffectPlayer] to trigger this callback function.
    /// Restrictions: None.
    /// Caution: This callback is a high-frequency callback, please do not perform time-consuming operations in this callback.
    ///
    /// @param data Audio data in PCM format.
    /// @param dataLength Length of the data.
    /// @param param Parameters of the audio frame.
    /// @param timestamp The audio frame timestamp, starting from 0 when capture is started, the unit is milliseconds (It is effective when there is one and only one stream).
    virtual void onProcessPlaybackAudioData(unsigned char * /*data*/, unsigned int /*dataLength*/,
                                            ZGFlutterAudioFrameParam * /*param*/, double /*timestamp*/) {

    }
};

class FLUTTER_PLUGIN_EXPORT ZegoCustomAudioProcessManager{
public:
    static std::shared_ptr<ZegoCustomAudioProcessManager> getInstance();
    
    /// Set up callback handler for custom audio processing.
    ///
    /// Available since: 1.13.0
    /// Description: When the custom audio processing is enabled, the custom audio processing callback is set through this function, and the developer can modify the processed audio frame data in the callback.
    /// Use cases: If the developer wants to implement special functions (such as voice change, bel canto, etc.) through custom processing after the audio data is collected or before the remote audio data is drawn for rendering.
    /// When to call: After creating the engine.
    /// Restrictions: None.
    ///
    /// @param handler Callback handler for custom audio processing.
    void setCustomAudioProcessHandler(std::shared_ptr<IZegoFlutterCustomAudioProcessHandler> handler);

    /// Get the custom audio process handler
    std::shared_ptr<IZegoFlutterCustomAudioProcessHandler> getHandler();

private:
    std::shared_ptr<IZegoFlutterCustomAudioProcessHandler> handler_ = nullptr;
};

#endif  // ZEGO_CUSTOM_AUDIO_PROCESS_MANAGER_H_
