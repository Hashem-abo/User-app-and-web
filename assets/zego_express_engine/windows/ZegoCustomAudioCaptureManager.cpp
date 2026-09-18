#include "include/zego_express_engine/ZegoCustomAudioCaptureManager.h"
#include <ZegoExpressSDK.h>

static std::shared_ptr<ZegoCustomAudioCaptureManager> instance_ = nullptr;
static std::once_flag singletonFlag;

std::shared_ptr<ZegoCustomAudioCaptureManager> ZegoCustomAudioCaptureManager::getInstance() {
    std::call_once(singletonFlag,
                   [&] { instance_ = std::make_shared<ZegoCustomAudioCaptureManager>(); });
    return instance_;
}

void ZegoCustomAudioCaptureManager::sendCustomAudioCaptureAACData(
    unsigned char *data, unsigned int dataLength, unsigned int configLength,
    unsigned long long referenceTimeMillisecond, unsigned int samples,
    ZGFlutterAudioFrameParam param, ZGFlutterPublishChannel channel) {
    ZEGO::EXPRESS::ZegoAudioFrameParam audioFrameParam = ZEGO::EXPRESS::ZegoAudioFrameParam();
    audioFrameParam.channel = ZEGO::EXPRESS::ZegoAudioChannel(param.channel);
    audioFrameParam.sampleRate = ZEGO::EXPRESS::ZegoAudioSampleRate(param.sampleRate);
    if (ZEGO::EXPRESS::ZegoExpressSDK::getEngine()) {
        ZEGO::EXPRESS::ZegoExpressSDK::getEngine()->sendCustomAudioCaptureAACData(
            data, dataLength, configLength, referenceTimeMillisecond, samples, audioFrameParam,
            ZEGO::EXPRESS::ZegoPublishChannel(channel));
    }
}

void ZegoCustomAudioCaptureManager::sendCustomAudioCaptureOpusData(unsigned char *data,
                                                                  unsigned int dataLength,
                                                                  unsigned long long referenceTimeMillisecond,
                                                                  unsigned int samples,
                                                                  ZGFlutterAudioFrameParam param,
                                                                  ZGFlutterPublishChannel channel) {
    ZEGO::EXPRESS::ZegoAudioFrameParam audioFrameParam = ZEGO::EXPRESS::ZegoAudioFrameParam();
    audioFrameParam.channel = ZEGO::EXPRESS::ZegoAudioChannel(param.channel);
    audioFrameParam.sampleRate = ZEGO::EXPRESS::ZegoAudioSampleRate(param.sampleRate);
    if (ZEGO::EXPRESS::ZegoExpressSDK::getEngine()) {
        ZEGO::EXPRESS::ZegoExpressSDK::getEngine()->sendCustomAudioCaptureOpusData(
            data, dataLength, referenceTimeMillisecond, samples, audioFrameParam,
            ZEGO::EXPRESS::ZegoPublishChannel(channel));
    }
}

void ZegoCustomAudioCaptureManager::sendCustomAudioCapturePCMData(unsigned char *data,
                                                                  unsigned int dataLength,
                                                                  ZGFlutterAudioFrameParam param,
                                                                  ZGFlutterPublishChannel channel) {
    ZEGO::EXPRESS::ZegoAudioFrameParam audioFrameParam = ZEGO::EXPRESS::ZegoAudioFrameParam();
    audioFrameParam.channel = ZEGO::EXPRESS::ZegoAudioChannel(param.channel);
    audioFrameParam.sampleRate = ZEGO::EXPRESS::ZegoAudioSampleRate(param.sampleRate);
    if (ZEGO::EXPRESS::ZegoExpressSDK::getEngine()) {
        ZEGO::EXPRESS::ZegoExpressSDK::getEngine()->sendCustomAudioCapturePCMData(
            data, dataLength, audioFrameParam, ZEGO::EXPRESS::ZegoPublishChannel(channel));
    }
}

void ZegoCustomAudioCaptureManager::fetchCustomAudioRenderPCMData(unsigned char *data,
                                                                  unsigned int dataLength,
                                                                  ZGFlutterAudioFrameParam param) {
    ZEGO::EXPRESS::ZegoAudioFrameParam audioFrameParam = ZEGO::EXPRESS::ZegoAudioFrameParam();
    audioFrameParam.channel = ZEGO::EXPRESS::ZegoAudioChannel(param.channel);
    audioFrameParam.sampleRate = ZEGO::EXPRESS::ZegoAudioSampleRate(param.sampleRate);
    if (ZEGO::EXPRESS::ZegoExpressSDK::getEngine()) {
        ZEGO::EXPRESS::ZegoExpressSDK::getEngine()->fetchCustomAudioRenderPCMData(data, dataLength,
                                                                   audioFrameParam);
    }
}

void ZegoCustomAudioCaptureManager::sendReferenceAudioPCMData(unsigned char *data,
                                                              unsigned int dataLength,
                                                              ZGFlutterAudioFrameParam param) {
    ZEGO::EXPRESS::ZegoAudioFrameParam audioFrameParam = ZEGO::EXPRESS::ZegoAudioFrameParam();
    audioFrameParam.channel = ZEGO::EXPRESS::ZegoAudioChannel(param.channel);
    audioFrameParam.sampleRate = ZEGO::EXPRESS::ZegoAudioSampleRate(param.sampleRate);
    if (ZEGO::EXPRESS::ZegoExpressSDK::getEngine()) {
        ZEGO::EXPRESS::ZegoExpressSDK::getEngine()->sendReferenceAudioPCMData(data, dataLength, audioFrameParam);
    }
}
