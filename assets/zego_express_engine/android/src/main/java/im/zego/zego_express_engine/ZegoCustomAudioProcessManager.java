package im.zego.zego_express_engine;

public class ZegoCustomAudioProcessManager {
    private volatile static ZegoCustomAudioProcessManager singleton;

    private static IZegoFlutterCustomAudioProcessHandler mHander;

    public ZegoCustomAudioProcessManager() {
    }

    public static synchronized ZegoCustomAudioProcessManager getInstance() {
        if (singleton == null) {
            singleton = new ZegoCustomAudioProcessManager();
        }
        return singleton;
    }


    public void setCustomAudioProcessHandler(IZegoFlutterCustomAudioProcessHandler handler) {
        mHander = handler;
    }

    public IZegoFlutterCustomAudioProcessHandler getHandler() {
        return mHander;
    }

}
