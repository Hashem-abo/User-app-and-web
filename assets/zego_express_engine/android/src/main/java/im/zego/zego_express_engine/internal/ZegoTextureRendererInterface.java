//
//  android
//  im.zego.zego_express_engine
//
//  Created by Patrick Fu on 2020-04-03.
//  Copyright © 2020 Zego. All rights reserved.
//

package im.zego.zego_express_engine.internal;

public interface ZegoTextureRendererInterface {

    Long getTextureID();

    void updateRenderSize(final int width, final int height);

    void release();

    Object getSurface();

}
