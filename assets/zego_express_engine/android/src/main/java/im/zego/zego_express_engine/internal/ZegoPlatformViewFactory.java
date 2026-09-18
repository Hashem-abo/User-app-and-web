//
//  android
//  im.zego.zego_express_engine
//
//  Created by Patrick Fu on 2020-04-03.
//  Copyright © 2020 Zego. All rights reserved.
//

package im.zego.zego_express_engine.internal;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Locale;

import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ZegoPlatformViewFactory extends PlatformViewFactory {

    private volatile static ZegoPlatformViewFactory instance;

    private final HashMap<Integer, PlatformView> platformViews;

    private ZegoPlatformViewFactory(MessageCodec<Object> createArgsCodec) {
        super(createArgsCodec);
        this.platformViews = new HashMap<>();
    }

    public static ZegoPlatformViewFactory getInstance() {
        if (instance == null) {
            synchronized (ZegoPlatformViewFactory.class) {
                if (instance == null) {
                    instance = new ZegoPlatformViewFactory(StandardMessageCodec.INSTANCE);
                }
            }
        }
        return instance;
    }

    /// Called when dart invoke `destroyPlatformView`
    Boolean destroyPlatformView(int viewID) {

        PlatformView platformView = this.platformViews.get(viewID);

        if (platformView == null) {
            ZegoLog.log("[destroyPlatformView] platform view for viewID:%d not exists", viewID);
            logCurrentPlatformViews();
            return false;
        }

        ZegoLog.log("[destroyPlatformView] viewID:%d, view:%s", viewID, platformView.getView() == null ? "null" : platformView.hashCode());

        this.platformViews.remove(viewID);

        logCurrentPlatformViews();

        return true;
    }

    /// Get PlatformView to pass to native when dart invoke `startPreview` or `startPlayingStream`
    public PlatformView getPlatformView(int viewID) {

        ZegoLog.log("[getPlatformView] viewID:%d", viewID);

        logCurrentPlatformViews();

        return this.platformViews.get(viewID);
    }


    private void addPlatformView(int viewID, PlatformView view) {

        ZegoLog.log("[createPlatformView] viewID:%d, view:%s", viewID, view.hashCode());

        this.platformViews.put(viewID, view);

        logCurrentPlatformViews();
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        PlatformView view = null;
        if (args instanceof String) {
            String viewType = (String) args;
            if (viewType.equals("surface")) {
                view = new ZegoPlatformView(context);
            } else if (viewType.equals("texture")) {
                view = new ZegoPlatformTextureView(context);
            }
        }
        if (view == null) {
            view = new ZegoPlatformView(context);
        }
        this.addPlatformView(viewId, view);
        return view;
    }

    private void logCurrentPlatformViews() {
        StringBuilder desc = new StringBuilder();
        for (Integer id: this.platformViews.keySet()) {
            PlatformView eachPlatformView = this.platformViews.get(id);
            if (eachPlatformView == null) {
                continue;
            }
            desc.append(String.format(Locale.ENGLISH, "[ID:%d|View:%s] ", id, eachPlatformView.getView() == null ? "null" : eachPlatformView.hashCode()));
        }
        ZegoLog.log("[ZegoPlatformViewFactory] currentPlatformViews: %s", desc.toString());
    }
}
