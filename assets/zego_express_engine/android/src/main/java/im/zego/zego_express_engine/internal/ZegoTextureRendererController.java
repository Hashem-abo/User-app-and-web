//
//  android
//  im.zego.zego_express_engine
//
//  Created by Patrick Fu on 2020-04-03.
//  Copyright © 2020 Zego. All rights reserved.
//

package im.zego.zego_express_engine.internal;

import android.graphics.SurfaceTexture;

import java.util.HashMap;
import java.util.Locale;

import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.ZegoMediaPlayer;
import im.zego.zegoexpress.constants.ZegoPublishChannel;
import im.zego.zegoexpress.entity.ZegoCanvas;
import im.zego.zegoexpress.entity.ZegoPlayerConfig;
import io.flutter.view.TextureRegistry;

public class ZegoTextureRendererController {

    private volatile static ZegoTextureRendererController instance;

    private HashMap<Long, ZegoTextureRendererInterface> renderers;

    public HashMap<ZegoPublishChannel, ZegoCanvas> previewCanvasInUse = new HashMap<>();
    // Only valid when using ZegoSurfaceTextureRenderer
    public HashMap<ZegoPublishChannel, Long> previewTextureInUse = new HashMap<>();

    public HashMap<String, ZegoCanvas> playerCanvasInUse = new HashMap<>(); // Key is playing streamID
    // Only valid when using ZegoSurfaceTextureRenderer
    public HashMap<String, Long> playerTextureInUse = new HashMap<>(); // Key is playing streamID

    public HashMap<String, ZegoPlayerConfig> playerConfigInUse = new HashMap<>(); // Key is playing streamID

    public HashMap<Integer, ZegoCanvas> mediaPlayerCanvasInUse = new HashMap<>(); // Key is media player index
    // Only valid when using ZegoSurfaceTextureRenderer
    public HashMap<Integer, Long> mediaPlayerTextureInUse = new HashMap<>(); // Key is media player index

    public static ZegoTextureRendererController getInstance() {
        if (instance == null) {
            synchronized (ZegoTextureRendererController.class) {
                if (instance == null) {
                    instance = new ZegoTextureRendererController();
                    instance.renderers = new HashMap<>();
                }
            }
        }
        return instance;
    }

    /// Called when dart invoke `createTextureRenderer`
    /// @return textureID
    Long createTextureRenderer(TextureRegistry.SurfaceTextureEntry textureEntry, int viewWidth, int viewHeight, Object args) {

        ZegoTextureRendererInterface renderer;
        if (args instanceof String) {
            if (args.equals("surfacetexture")) {
                renderer = new ZegoSurfaceTextureRenderer(textureEntry, viewWidth, viewHeight);
            } else {
                renderer = new ZegoTextureRenderer(textureEntry, viewWidth, viewHeight);
            }
        } else {
            renderer = new ZegoTextureRenderer(textureEntry, viewWidth, viewHeight);
        }
        

        ZegoLog.log("[createTextureRenderer] textureID:%d, renderer:%s", renderer.getTextureID(), renderer.hashCode());

        this.renderers.put(renderer.getTextureID(), renderer);

        logCurrentRenderers();

        return renderer.getTextureID();
    }

    /// Called when dart invoke `updateTextureRendererSize`
    Boolean updateTextureRendererSize(Long textureID, int viewWidth, int viewHeight) {

        ZegoTextureRendererInterface renderer = this.renderers.get(textureID);

        if (renderer == null) {
            ZegoLog.log("[updateTextureRendererSize] renderer for textureID:%d not exists", textureID);
            logCurrentRenderers();
            return false;
        }

        // ZegoLog.log("[updateTextureRendererSize] textureID:%d, renderer:%s", textureID, renderer.hashCode());

        Object originSurface = renderer.getSurface();

        renderer.updateRenderSize(viewWidth, viewHeight);

        Object surface = renderer.getSurface();

        for (ZegoPublishChannel channel : previewCanvasInUse.keySet()) {
            ZegoCanvas canvas = previewCanvasInUse.get(channel);
            if (canvas != null && originSurface.equals(canvas.view)) {
                canvas.view = surface;
                ZegoExpressEngine.getEngine().startPreview(canvas, channel);
                return true;
            }
        }

        for (String streamID : playerCanvasInUse.keySet()) {
            ZegoCanvas canvas = playerCanvasInUse.get(streamID);
            ZegoPlayerConfig config = playerConfigInUse.get(streamID);
            if (canvas != null && originSurface.equals(canvas.view)) {
                canvas.view = surface;
                ZegoExpressEngine.getEngine().startPlayingStream(streamID, canvas, config);
                return true;
            }
        }

        for (Integer index : mediaPlayerCanvasInUse.keySet()) {
            ZegoCanvas canvas = mediaPlayerCanvasInUse.get(index);
            if (canvas != null && originSurface.equals(canvas.view)) {
                ZegoMediaPlayer mediaPlayer = ZegoExpressEngineMethodHandler.getMediaPlayer(index);
                if (mediaPlayer != null) {
                    canvas.view = surface;
                    mediaPlayer.setPlayerCanvas(canvas);
                }
            }
        }

        logCurrentRenderers();

        return true;
    }

    /// Called when dart invoke `destroyTextureRenderer`
    Boolean destroyTextureRenderer(Long textureID) {

        ZegoTextureRendererInterface renderer = this.renderers.get(textureID);

        if (renderer == null) {
            ZegoLog.log("[destroyTextureRenderer] renderer for textureID:%d not exists", textureID);
            logCurrentRenderers();
            return false;
        }

        ZegoLog.log("[destroyTextureRenderer] textureID:%d, renderer: %d", textureID, renderer.hashCode());

        this.renderers.remove(textureID);

        // Clear any cached bindings for this textureID
        previewTextureInUse.values().remove(textureID);
        playerTextureInUse.values().remove(textureID);
        mediaPlayerTextureInUse.values().remove(textureID);

        renderer.release();

        logCurrentRenderers();

        return true;
    }

    /// Get TextureRenderer to pass to native when dart invoke `startPreview` or `startPlayingStream`
    ZegoTextureRendererInterface getTextureRenderer(Long textureID) {

        ZegoTextureRendererInterface renderer = this.renderers.get(textureID);

        ZegoLog.log("[getTextureRenderer] textureID:%d, renderer:%s", textureID, renderer == null ? "null" : renderer.hashCode());

        logCurrentRenderers();

        return renderer;
    }

    private void logCurrentRenderers() {
        StringBuilder desc = new StringBuilder();
        for (Long id: this.renderers.keySet()) {
            ZegoTextureRendererInterface eachRenderer = this.renderers.get(id);
            desc.append(String.format(Locale.ENGLISH, "[ID:%d|Rnd:%s] ", eachRenderer.getTextureID(), eachRenderer == null ? "null" : eachRenderer.hashCode()));
        }
        ZegoLog.log("[ZegoTextureRendererController] currentRenderers: %s", desc.toString());
    }

}
