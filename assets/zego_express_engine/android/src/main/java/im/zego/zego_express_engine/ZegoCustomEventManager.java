//
//  ZegoCustomEventManager.java
//  im.zego.zego_express_engine
//
//  Created by zego on 2025/10/31.
//

package im.zego.zego_express_engine;

public class ZegoCustomEventManager {
    private volatile static ZegoCustomEventManager instance;
    private IZegoFlutterCustomEventHandler handler;

    private ZegoCustomEventManager() {
    }

    /**
     * Get the custom event manager instance
     */
    public static synchronized ZegoCustomEventManager getInstance() {
        if (instance == null) {
            synchronized (ZegoCustomEventManager.class) {
                if (instance == null) {
                    instance = new ZegoCustomEventManager();
                }
            }
        }
        return instance;
    }

    /**
     * Set custom event handler
     */
    public void setCustomEventHandler(IZegoFlutterCustomEventHandler handler) {
        this.handler = handler;
    }

    /**
     * Get custom event handler
     */
    public IZegoFlutterCustomEventHandler getCustomEventHandler() {
        return handler;
    }
}

