package im.zego.zego_express_engine;

import im.zego.zegoexpress.callback.IZegoAudioDataHandler;

/**
 * Manager for audio data callbacks (onCapturedAudioData, onPlaybackAudioData, etc.).
 * Reference: ZegoCustomAudioProcessManager. Apps can set a handler to receive raw audio data.
 */
public class ZegoAudioDataManager {
    private volatile static ZegoAudioDataManager singleton;

    private volatile IZegoAudioDataHandler handler;

    public ZegoAudioDataManager() {
    }

    public static synchronized ZegoAudioDataManager getInstance() {
        if (singleton == null) {
            singleton = new ZegoAudioDataManager();
        }
        return singleton;
    }

    public void setAudioDataHandler(IZegoAudioDataHandler h) {
        handler = h;
    }

    public IZegoAudioDataHandler getHandler() {
        return handler;
    }
}
