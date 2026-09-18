#ifndef ZEGO_AUDIO_DATA_MANAGER_H_
#define ZEGO_AUDIO_DATA_MANAGER_H_

#include "ZegoCustomVideoDefine.h"
#include <ZegoExpressSDK.h>
#include <memory>

/// Manager for audio data callbacks (onCapturedAudioData, onPlaybackAudioData, etc.).
/// Reference: ZegoCustomAudioProcessManager. Apps can set a handler to receive raw audio data.
class FLUTTER_PLUGIN_EXPORT ZegoAudioDataManager {
public:
    static std::shared_ptr<ZegoAudioDataManager> getInstance();

    void setAudioDataHandler(std::shared_ptr<ZEGO::EXPRESS::IZegoAudioDataHandler> handler);
    std::shared_ptr<ZEGO::EXPRESS::IZegoAudioDataHandler> getHandler();

private:
    std::shared_ptr<ZEGO::EXPRESS::IZegoAudioDataHandler> handler_ = nullptr;
};

#endif  // ZEGO_AUDIO_DATA_MANAGER_H_
