//
//  ZegoCustomEventManager.m
//  Pods
//
//  Created by zego on 2025/10/31.
//

#import "ZegoCustomEventManager.h"

@interface ZegoCustomEventManager() <ZegoFlutterCustomEventHandler>

@property (nonatomic, weak) id<ZegoFlutterCustomEventHandler> handler;

@end

@implementation ZegoCustomEventManager

+ (instancetype)sharedInstance {
    static ZegoCustomEventManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZegoCustomEventManager alloc] init];
    });
    return instance;
}

- (void)setCustomEventHandler:(id<ZegoFlutterCustomEventHandler>)handler {
    self.handler = handler;
}

- (id<ZegoFlutterCustomEventHandler>)getCustomEventHandler {
    return self.handler;
}

@end
