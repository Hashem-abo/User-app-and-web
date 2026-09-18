//
//  ZegoCustomEventManager.h
//  Pods
//
//  Created by zego on 2025/10/31.
//

#ifndef ZegoCustomEventManager_h
#define ZegoCustomEventManager_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZegoFlutterCustomEventHandler <NSObject>

@optional

- (void)onPlayerRecvMediaSideInfo:(NSData *)data streamID:(NSString *)streamID timestampNs:(unsigned long long)timestampNs;

@end

@interface ZegoCustomEventManager : NSObject

/// Get the custom event manager instance
+ (instancetype)sharedInstance;

- (void)setCustomEventHandler:(nullable id<ZegoFlutterCustomEventHandler>)handler;

- (id<ZegoFlutterCustomEventHandler>)getCustomEventHandler;

@end

NS_ASSUME_NONNULL_END

#endif /* ZegoCustomEventManager_h */
