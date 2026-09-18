#include "include/zego_express_engine/ZegoCustomAudioProcessManager.h"

static std::shared_ptr<ZegoCustomAudioProcessManager> instance_ = nullptr;
static std::once_flag singletonFlag;

std::shared_ptr<ZegoCustomAudioProcessManager> ZegoCustomAudioProcessManager::getInstance() {
    std::call_once(singletonFlag, [&] {
        instance_ = std::make_shared<ZegoCustomAudioProcessManager>();
    });
    return instance_;
}

std::shared_ptr<IZegoFlutterCustomAudioProcessHandler> ZegoCustomAudioProcessManager::getHandler() {
    return handler_;
}

void ZegoCustomAudioProcessManager::setCustomAudioProcessHandler(std::shared_ptr<IZegoFlutterCustomAudioProcessHandler> handler) {
    handler_ = handler;
}   