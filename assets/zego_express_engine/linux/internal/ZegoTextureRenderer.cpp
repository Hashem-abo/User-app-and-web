#include "ZegoTextureRenderer.h"

#include <cassert>
#include <iostream>

ZegoTextureRenderer::ZegoTextureRenderer() {}

void ZegoTextureRenderer::CreateTexture(ZFTextureRegistrar *texture_registrar, uint32_t width,
                                        uint32_t height) {

    textureRegistrar_ = texture_registrar;
    width_ = width;
    height_ = height;

    video_output_ = std::make_shared<VideoOutput>();
    texture_ = zego_texture_new(video_output_);
    FL_PIXEL_BUFFER_TEXTURE_GET_CLASS(texture_)->copy_pixels = zego_texture_copy_pixels;
    fl_texture_registrar_register_texture(texture_registrar, FL_TEXTURE(texture_));
    textureID_ = reinterpret_cast<int64_t>(FL_TEXTURE(texture_));
}

void ZegoTextureRenderer::DestroyTexture() {
    if (textureRegistrar_ && texture_) {
        fl_texture_registrar_unregister_texture(textureRegistrar_, FL_TEXTURE(texture_));
    }
    texture_ = nullptr;
    textureRegistrar_ = nullptr;
}

ZegoTextureRenderer::~ZegoTextureRenderer() {
    // Defer releasing the renderer's shared_ptr to the next main-loop iteration.
    // On Linux, Flutter's raster == platform thread, so unregister() does NOT wait
    // for an already-scheduled copy_pixels + glTexImage2D to finish. Releasing the
    // shared_ptr here (during renderers_.clear(), which runs right after DestroyTexture)
    // could drop the last reference while an in-flight frame is still being read.
    // By the time the idle callback runs, the current frame has completed.
    if (video_output_) {
        std::shared_ptr<VideoOutput> vo = std::move(video_output_);
        g_idle_add_full(
            G_PRIORITY_LOW,
            [](gpointer data) -> gboolean {
                delete static_cast<std::shared_ptr<VideoOutput> *>(data);
                return G_SOURCE_REMOVE;
            },
            new std::shared_ptr<VideoOutput>(std::move(vo)), nullptr);
    }
}

bool ZegoTextureRenderer::updateSrcFrameBuffer(uint8_t *data, uint32_t data_length,
                                               ZEGO::EXPRESS::ZegoVideoFrameParam frameParam) {
    const std::lock_guard<std::mutex> lock(bufferMutex_);
    if (!TextureRegistered()) {
        return false;
    }

    updateRenderSize(frameParam.width, frameParam.height);
    srcStride_ = frameParam.strides[0];

    if (srcBuffer_.size() != data_length) {
        srcBuffer_.resize(data_length);
    }
    std::copy(data, data + data_length, srcBuffer_.data());

    auto video_output = video_output_;
    if (!video_output) {
        return false;
    }

    {
        const std::lock_guard<std::mutex> vlock(video_output->mutex);
        if (video_output->buffer.size() != data_length) {
            video_output->buffer.resize(data_length);
        }

        switch (frameParam.format) {
        case ZEGO::EXPRESS::ZEGO_VIDEO_FRAME_FORMAT_RGBA32:
            std::copy(srcBuffer_.data(), srcBuffer_.data() + data_length,
                      video_output->buffer.data());
            break;
        case ZEGO::EXPRESS::ZEGO_VIDEO_FRAME_FORMAT_BGRA32:
            srcFrameFormatToFlutterFormat<VideoFormatBGRAPixel>(video_output->buffer.data());
            break;
        case ZEGO::EXPRESS::ZEGO_VIDEO_FRAME_FORMAT_ARGB32:
            srcFrameFormatToFlutterFormat<VideoFormatARGBPixel>(video_output->buffer.data());
            break;
        case ZEGO::EXPRESS::ZEGO_VIDEO_FRAME_FORMAT_ABGR32:
            srcFrameFormatToFlutterFormat<VideoFormatABGRPixel>(video_output->buffer.data());
            break;
        default:
            std::copy(srcBuffer_.data(), srcBuffer_.data() + data_length,
                      video_output->buffer.data());
            break;
        }

        video_output->video_width = frameParam.width;
        video_output->video_height = frameParam.height;
    }

    if (textureRegistrar_ && texture_) {
        fl_texture_registrar_mark_texture_frame_available(textureRegistrar_, FL_TEXTURE(texture_));
    }

    return true;
};

bool ZegoTextureRenderer::TextureRegistered() {
    return textureRegistrar_ && texture_ && textureID_ > -1;
}

template <typename T>
void ZegoTextureRenderer::srcFrameFormatToFlutterFormat(uint8_t *dst_data) {

    T *src = reinterpret_cast<T *>(srcBuffer_.data());
    FlutterDesktopPixel *dst = reinterpret_cast<FlutterDesktopPixel *>(dst_data);

    for (uint32_t y = 0; y < height_; y++) {
        for (uint32_t x = 0; x < width_; x++) {
            uint32_t sp = (y * width_) + x;
            if (isUseMirror_) {
                // Calculates mirrored pixel position.
                uint32_t tp = (y * width_) + ((width_ - 1) - x);
                dst[tp].r = src[sp].r;
                dst[tp].g = src[sp].g;
                dst[tp].b = src[sp].b;
                dst[tp].a = 255;
            } else {
                dst[sp].r = src[sp].r;
                dst[sp].g = src[sp].g;
                dst[sp].b = src[sp].b;
                dst[sp].a = 255;
            }
        }
    }
}
