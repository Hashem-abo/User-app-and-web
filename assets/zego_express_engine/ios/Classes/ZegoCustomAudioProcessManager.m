//
//  ZegoCustomAudioProcessManager.m
//  Pods
//
//  Created by 27 on 2023/2/2.
//

#import "ZegoCustomAudioProcessManager.h"

@interface ZegoCustomAudioProcessManager()

@property (nonatomic, weak) id<ZegoFlutterCustomAudioProcessHandler> handler;

@end

@implementation ZegoCustomAudioProcessManager

+ (instancetype)sharedInstance {
    static ZegoCustomAudioProcessManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZegoCustomAudioProcessManager alloc] init];
    });
    return instance;
}

-(void)setCustomAudioProcessHandler:(id<ZegoFlutterCustomAudioProcessHandler>)handler {
    
    self.handler = handler;
}

- (id<ZegoFlutterCustomAudioProcessHandler>)getHandler {
    return self.handler;
}

@end
