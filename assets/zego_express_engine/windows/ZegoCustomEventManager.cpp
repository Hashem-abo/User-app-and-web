#include "include/zego_express_engine/ZegoCustomEventManager.h"

static std::shared_ptr<ZegoCustomEventManager> instance_ = nullptr;
static std::once_flag singletonFlag;

std::shared_ptr<ZegoCustomEventManager> ZegoCustomEventManager::getInstance() {
    std::call_once(singletonFlag, [&] {
        instance_ = std::make_shared<ZegoCustomEventManager>();
    });
    return instance_;
}

std::shared_ptr<IZegoFlutterCustomEventHandler> ZegoCustomEventManager::getHandler() {
    return handler_;
}

void ZegoCustomEventManager::setCustomEventHandler(std::shared_ptr<IZegoFlutterCustomEventHandler> handler) {
    handler_ = handler;
}   