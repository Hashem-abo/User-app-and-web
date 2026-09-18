//
//  android
//  im.zego.zego_express_engine
//
//  Created by Patrick Fu on 2020-04-03.
//  Copyright © 2020 Zego. All rights reserved.
//

package im.zego.zego_express_engine.internal;

import android.content.Context;
import android.view.View;
import android.view.TextureView;

import io.flutter.plugin.platform.PlatformView;

public class ZegoPlatformTextureView implements PlatformView {

    private final TextureView textureView;
    ZegoPlatformTextureView(Context context) {
        this.textureView = new TextureView(context);
        ZegoLog.log("[ZegoPlatformTextureView] [init] textureView:%s", this.textureView.hashCode());
    }

    @Override
    public View getView() {
        return this.textureView;
    }

    @Override
    public void dispose() {
        ZegoLog.log("[ZegoPlatformTextureView] [dispose] textureView:%s", this.textureView.hashCode());
        // Can not set textureView null, flutter may getView() after dispose()
    }
}
