#ifndef ZEGO_CUSTOM_EVENT_MANAGER_H_
#define ZEGO_CUSTOM_EVENT_MANAGER_H_

#include "ZegoCustomVideoDefine.h"

class FLUTTER_PLUGIN_EXPORT IZegoFlutterCustomEventHandler {
protected:
    virtual ~IZegoFlutterCustomEventHandler() {}
public:

    virtual void onPlayerRecvMediaSideInfo(const unsigned char *data, int dataLength, const char *streamID, unsigned long long timestampNs) {}

};

class FLUTTER_PLUGIN_EXPORT ZegoCustomEventManager{
public:
    static std::shared_ptr<ZegoCustomEventManager> getInstance();
    
    void setCustomEventHandler(std::shared_ptr<IZegoFlutterCustomEventHandler> handler);

    std::shared_ptr<IZegoFlutterCustomEventHandler> getHandler();

private:
    std::shared_ptr<IZegoFlutterCustomEventHandler> handler_ = nullptr;
};

#endif  // ZEGO_CUSTOM_EVENT_MANAGER_H_
