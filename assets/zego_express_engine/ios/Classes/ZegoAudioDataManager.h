//
//  ZegoAudioDataManager.h
//  Pods
//
//  Manager for audio data callbacks (onCapturedAudioData, onPlaybackAudioData, etc.).
//  Reference: ZegoCustomAudioProcessManager. Apps can set a handler to receive raw audio data.
//

#ifndef ZegoAudioDataManager_h
#define ZegoAudioDataManager_h

#import <Foundation/Foundation.h>
#import "ZegoCustomVideoDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoFlutterAudioDataHandler <NSObject>

@optional

/// Captured audio data callback (from startAudioDataObserver, mask 0b01).
- (void)onCapturedAudioData:(const unsigned char *)data
                dataLength:(unsigned int)dataLength
                     param:(ZGFlutterAudioFrameParam *)param;

/// Playback audio data callback (from startAudioDataObserver, mask 0b10).
- (void)onPlaybackAudioData:(const unsigned char *)data
                dataLength:(unsigned int)dataLength
                     param:(ZGFlutterAudioFrameParam *)param;

/// Mixed audio data callback (from startAudioDataObserver, mask 0x04).
- (void)onMixedAudioData:(const unsigned char *)data
              dataLength:(unsigned int)dataLength
                   param:(ZGFlutterAudioFrameParam *)param;

/// Player audio data callback (from startAudioDataObserver, mask 0x08).
- (void)onPlayerAudioData:(const unsigned char *)data
               dataLength:(unsigned int)dataLength
                    param:(ZGFlutterAudioFrameParam *)param
                 streamID:(NSString *)streamID;

@end

@interface ZegoAudioDataManager : NSObject

+ (instancetype)sharedInstance;

- (void)setAudioDataHandler:(nullable id<ZegoFlutterAudioDataHandler>)handler;
- (nullable id<ZegoFlutterAudioDataHandler>)getHandler;

@end

NS_ASSUME_NONNULL_END

#endif /* ZegoAudioDataManager_h */
