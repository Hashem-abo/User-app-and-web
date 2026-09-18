//
//  android
//  im.zego.zego_express_engine
//
//  Created by Patrick Fu on 2020-04-03.
//  Copyright © 2020 Zego. All rights reserved.
//

package im.zego.zego_express_engine.internal;

import android.graphics.SurfaceTexture;

import io.flutter.view.TextureRegistry;

public class ZegoSurfaceTextureRenderer implements ZegoTextureRendererInterface {

    private final TextureRegistry.SurfaceTextureEntry textureEntry;
    private final SurfaceTexture surfaceTexture;
    private int viewWidth;
    private int viewHeight;

    ZegoSurfaceTextureRenderer(TextureRegistry.SurfaceTextureEntry textureEntry, int viewWidth, int viewHeight) {
        this.textureEntry = textureEntry;
        this.surfaceTexture = textureEntry.surfaceTexture();
        this.surfaceTexture.setDefaultBufferSize(viewWidth, viewHeight);

        this.viewWidth = viewWidth;
        this.viewHeight = viewHeight;
    }

    @Override
    public void updateRenderSize(final int width, final int height) {

        if (this.viewWidth != width || this.viewHeight != height) {
            this.viewWidth = width;
            this.viewHeight = height;

            this.surfaceTexture.setDefaultBufferSize(viewWidth, viewHeight);
        }
    }

    @Override
    public void release() {
        this.textureEntry.release();

        if (this.surfaceTexture != null) {
            surfaceTexture.release();
        }

        ZegoLog.log("[ZegoSurfaceTextureRenderer] [release] renderer:%s", this.hashCode());
    }

    @Override
    public SurfaceTexture getSurface() {
        return this.surfaceTexture;
    }

    @Override
    public Long getTextureID() {
        return this.textureEntry.id();
    }

}
