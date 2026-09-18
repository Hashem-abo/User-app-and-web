//
//  IZegoFlutterCustomEventHandler.java
//  im.zego.zego_express_engine
//
//  Created by zego on 2025/10/31.
//

package im.zego.zego_express_engine;

import java.nio.ByteBuffer;

/**
 * Interface for custom event handler
 */
public interface IZegoFlutterCustomEventHandler {
    /**
     * Callback when receiving MediaSideInfo (SEI data)
     * 
     * @param data SEI data
     * @param streamID Stream ID
     * @param timestampNs Timestamp in nanoseconds
     */
    void onPlayerRecvMediaSideInfo(ByteBuffer data, String streamID, long timestampNs);
}

