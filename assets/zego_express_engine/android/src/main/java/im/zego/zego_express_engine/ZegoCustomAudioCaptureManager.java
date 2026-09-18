package im.zego.zego_express_engine;

import java.nio.ByteBuffer;

import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.entity.ZegoAudioFrameParam;
import im.zego.zegoexpress.constants.ZegoAudioSampleRate;
import im.zego.zegoexpress.constants.ZegoAudioChannel;
import im.zego.zegoexpress.constants.ZegoPublishChannel;

public class ZegoCustomAudioCaptureManager {
    private volatile static ZegoCustomAudioCaptureManager singleton;

    public ZegoCustomAudioCaptureManager() {
    }

    public static synchronized ZegoCustomAudioCaptureManager getInstance() {
        if (singleton == null) {
            singleton = new ZegoCustomAudioCaptureManager();
        }
        return singleton;
    }


    public void sendCustomAudioCapturePCMData(ByteBuffer data, int dataLength,
                                              ZGFlutterAudioFrameParam param,
                                              ZGFlutterPublishChannel channel) {
        ZegoAudioFrameParam audioFrameParam = new ZegoAudioFrameParam();
        audioFrameParam.sampleRate = ZegoAudioSampleRate.getZegoAudioSampleRate(param.sampleRate.value());
        audioFrameParam.channel = ZegoAudioChannel.getZegoAudioChannel(param.channel.value());
        if (ZegoExpressEngine.getEngine() != null) {
            ZegoExpressEngine.getEngine().sendCustomAudioCapturePCMData(data, dataLength, audioFrameParam, ZegoPublishChannel.getZegoPublishChannel(channel.value()));
        }
    }

    public void sendCustomAudioCaptureOpusData(ByteBuffer data, int dataLength,
                                              long referenceTimeMillisecond, int samples,
                                              ZGFlutterAudioFrameParam param,
                                              ZGFlutterPublishChannel channel) {
        ZegoAudioFrameParam audioFrameParam = new ZegoAudioFrameParam();
        audioFrameParam.sampleRate = ZegoAudioSampleRate.getZegoAudioSampleRate(param.sampleRate.value());
        audioFrameParam.channel = ZegoAudioChannel.getZegoAudioChannel(param.channel.value());
        if (ZegoExpressEngine.getEngine() != null) {
            ZegoExpressEngine.getEngine().sendCustomAudioCaptureOpusData(data, dataLength, referenceTimeMillisecond, samples, audioFrameParam, ZegoPublishChannel.getZegoPublishChannel(channel.value()));
        }
    }

    public void sendCustomAudioCaptureAACData(ByteBuffer data, int dataLength, int configLength,
                                              long referenceTimeMillisecond, int samples,
                                              ZGFlutterAudioFrameParam param,
                                              ZGFlutterPublishChannel channel) {
        ZegoAudioFrameParam audioFrameParam = new ZegoAudioFrameParam();
        audioFrameParam.sampleRate = ZegoAudioSampleRate.getZegoAudioSampleRate(param.sampleRate.value());
        audioFrameParam.channel = ZegoAudioChannel.getZegoAudioChannel(param.channel.value());
        if (ZegoExpressEngine.getEngine() != null) {
            ZegoExpressEngine.getEngine().sendCustomAudioCaptureAACData(data, dataLength, configLength, referenceTimeMillisecond, samples, audioFrameParam, ZegoPublishChannel.getZegoPublishChannel(channel.value()));
        }
    }

    public void fetchCustomAudioRenderPCMData(ByteBuffer data, int dataLength,
                                              ZGFlutterAudioFrameParam param) {
        ZegoAudioFrameParam audioFrameParam = new ZegoAudioFrameParam();
        audioFrameParam.sampleRate = ZegoAudioSampleRate.getZegoAudioSampleRate(param.sampleRate.value());
        audioFrameParam.channel = ZegoAudioChannel.getZegoAudioChannel(param.channel.value());
        if (ZegoExpressEngine.getEngine() != null) {
            ZegoExpressEngine.getEngine().fetchCustomAudioRenderPCMData(data, dataLength, audioFrameParam);
        }
    }

    public void sendReferenceAudioPCMData(ByteBuffer data, int dataLength,
                                          ZGFlutterAudioFrameParam param) {
        ZegoAudioFrameParam audioFrameParam = new ZegoAudioFrameParam();
        audioFrameParam.sampleRate = ZegoAudioSampleRate.getZegoAudioSampleRate(param.sampleRate.value());
        audioFrameParam.channel = ZegoAudioChannel.getZegoAudioChannel(param.channel.value());
        if (ZegoExpressEngine.getEngine() != null) {
            ZegoExpressEngine.getEngine().sendReferenceAudioPCMData(data, dataLength, audioFrameParam);
        }
    }
}
