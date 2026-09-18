#include "include/zego_express_engine/ZegoAudioDataManager.h"

static std::shared_ptr<ZegoAudioDataManager> instance_ = nullptr;
static std::once_flag singletonFlag;

std::shared_ptr<ZegoAudioDataManager> ZegoAudioDataManager::getInstance() {
    std::call_once(singletonFlag, [&] {
        instance_ = std::make_shared<ZegoAudioDataManager>();
    });
    return instance_;
}

std::shared_ptr<ZEGO::EXPRESS::IZegoAudioDataHandler> ZegoAudioDataManager::getHandler() {
    return handler_;
}

void ZegoAudioDataManager::setAudioDataHandler(
    std::shared_ptr<ZEGO::EXPRESS::IZegoAudioDataHandler> handler) {
    handler_ = handler;
}
