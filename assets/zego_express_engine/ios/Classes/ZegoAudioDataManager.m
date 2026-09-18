//
//  ZegoAudioDataManager.m
//  Pods
//

#import "ZegoAudioDataManager.h"

@interface ZegoAudioDataManager ()

@property (nonatomic, weak) id<ZegoFlutterAudioDataHandler> handler;

@end

@implementation ZegoAudioDataManager

+ (instancetype)sharedInstance {
    static ZegoAudioDataManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZegoAudioDataManager alloc] init];
    });
    return instance;
}

- (void)setAudioDataHandler:(id<ZegoFlutterAudioDataHandler>)handler {
    self.handler = handler;
}

- (id<ZegoFlutterAudioDataHandler>)getHandler {
    return self.handler;
}

@end
