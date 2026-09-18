#pragma once

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <mutex>
#include <vector>

#define ZEGO_TEXTURE_TYPE (zego_texture_get_type())

G_DECLARE_FINAL_TYPE(ZegoTexture, zego_texture, ZEGO_TEXTURE, ZEGO_TEXTURE, FlPixelBufferTexture)

#define ZEGO_TEXTURE(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), zego_texture_get_type(), ZegoTexture))

// Owns the RGBA pixel buffer handed to Flutter via copy_pixels. Reference-counted
// (shared_ptr) so every thread that reads it keeps it alive for its use.
struct VideoOutput {
    std::mutex mutex;
    std::vector<uint8_t> buffer;
    int32_t video_width = 0;
    int32_t video_height = 0;
};

// Creates a ZegoTexture bound to |video_output| via a weak_ptr.
ZegoTexture *zego_texture_new(std::weak_ptr<VideoOutput> video_output);

gboolean zego_texture_copy_pixels(FlPixelBufferTexture *texture, const uint8_t **buffer,
                                  uint32_t *width, uint32_t *height, GError **error);
