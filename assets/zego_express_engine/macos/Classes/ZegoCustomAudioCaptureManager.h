//
//  ZegoCustomAudioCaptureManager.h
//  Pods
//
//  Created by 27 on 2023/2/2.
//

#ifndef ZegoCustomAudioCaptureManager_h
#define ZegoCustomAudioCaptureManager_h

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ZegoCustomVideoDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZegoCustomAudioCaptureManager : NSObject

/// Get the custom video capture manager instance
+ (instancetype)sharedInstance;

/// Sends AAC audio data produced by custom audio capture to the SDK (for the specified channel).
///
/// Available since: 2.20.0
/// Description: Sends the captured audio AAC data to the SDK.
/// Use cases: The customer needs to obtain input after acquisition from the existing audio stream, audio file, or customized acquisition system, and hand it over to the SDK for transmission.
/// When to call: After [enableCustomAudioIO] and publishing stream successfully.
/// Restrictions: None.
/// Related APIs: Enable the custom audio IO function [enableCustomAudioIO], and start the push stream [startPublishingStream].
///
/// @param data AAC buffer data.
/// @param dataLength The total length of the buffer data.
/// @param configLength The length of AAC specific config (Note: The AAC encoded data length is 'encodedLength = dataLength - configLength').Value range: [0,64]
/// @param timestamp The UNIX timestamp of this AAC audio frame.
/// @param samples The number of samples for this AAC audio frame.Value range: [480,512,1024,1960,2048].
/// @param param The param of this AAC audio frame.
/// @param channel Publish channel for capturing audio frames.
- (void)sendCustomAudioCaptureAACData:(unsigned char *)data
                           dataLength:(unsigned int)dataLength
                         configLength:(unsigned int)configLength
                            timestamp:(CMTime)timestamp
                              samples:(unsigned int)samples
                                param:(ZGFlutterAudioFrameParam *)param
                              channel:(ZGFlutterPublishChannel)channel;

/// Sends Opus audio data produced by custom audio capture to the SDK (for the specified channel).
///
/// Available since: 3.25.0
/// Description: Sends the captured audio Opus data to the SDK.
/// Use cases: 1.The customer needs to obtain input after acquisition from the existing audio stream, audio file, or customized acquisition system, and hand it over to the SDK for transmission. 2.Customers have their own requirements for special sound processing for Opus input sources. After the sound processing, the input will be sent to the SDK for transmission.
/// When to call: After [enableCustomAudioIO] and publishing stream successfully.
/// Restrictions: None.
/// Related APIs: Enable the custom audio IO function [enableCustomAudioIO], and start the push stream [startPublishingStream].
///
/// @param data Opus buffer data.
/// @param dataLength The total length of the buffer data.
/// @param referenceTimeMillisecond The UNIX timestamp of this Opus audio frame in millisecond.
/// @param samples The number of samples for this Opus audio frame.
/// @param param The param of this Opus audio frame.
/// @param channel Publish channel for capturing audio frames.
- (void)sendCustomAudioCaptureOpusData:(unsigned char *)data
                           dataLength:(unsigned int)dataLength
             referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond
                               samples:(unsigned int)samples
                                param:(ZGFlutterAudioFrameParam *)param
                              channel:(ZGFlutterPublishChannel)channel;

/// Sends PCM audio data produced by custom audio capture to the SDK (for the specified channel).
///
/// Available since: 1.10.0
/// Description: Sends the captured audio PCM data to the SDK.
/// Use cases: 1.The customer needs to obtain input after acquisition from the existing audio stream, audio file, or customized acquisition system, and hand it over to the SDK for transmission. 2.Customers have their own requirements for special sound processing for PCM input sources. After the sound processing, the input will be sent to the SDK for transmission.
/// When to call: After [enableCustomAudioIO] and publishing stream successfully.
/// Restrictions: None.
/// Related APIs: Enable the custom audio IO function [enableCustomAudioIO], and start the push stream [startPublishingStream].
///
/// @param data PCM buffer data.
/// @param dataLength The total length of the buffer data.
/// @param param The param of this PCM audio frame.
/// @param channel Publish channel for capturing audio frames.
- (void)sendCustomAudioCapturePCMData:(unsigned char *)data
                           dataLength:(unsigned int)dataLength
                                param:(ZGFlutterAudioFrameParam *)param
                              channel:(ZGFlutterPublishChannel)channel;

/// Fetches PCM audio data of the remote stream from the SDK for custom audio rendering.
///
/// Available since: 1.10.0
/// Description: Fetches PCM audio data of the remote stream from the SDK for custom audio rendering, it is recommended to use the system framework to periodically invoke this function to drive audio data rendering.
/// Use cases: When developers have their own rendering requirements, such as special applications or processing and rendering of the original PCM data that are pulled, it is recommended to use the custom audio rendering function of the SDK.
/// When to call: After [enableCustomAudioIO] and playing stream successfully.
/// Restrictions: None.
/// Related APIs: Enable the custom audio IO function [enableCustomAudioIO], and start the play stream [startPlayingStream].
///
/// @param data A block of memory for storing audio PCM data that requires user to manage the memory block's lifecycle, the SDK will copy the audio frame rendering data to this memory block.
/// @param dataLength The length of the audio data to be fetch this time (dataLength = duration * sampleRate * channels * 2(16 bit depth i.e. 2 Btye)).
/// @param param Specify the parameters of the fetched audio frame. sampleRate in ZegoAudioFrameParam must assignment
- (void)fetchCustomAudioRenderPCMData:(unsigned char *)data
                           dataLength:(unsigned int)dataLength
                                param:(ZGFlutterAudioFrameParam *)param;

/// Send the PCM audio data customized by the developer to the SDK, which is used as a reference for custom rendering audio to eliminate echo.
///
/// Available since：2.13.0.
/// Description：Developers use the audio device clock as the driver to capture PCM audio data, and use it for custom audio rendering after processing. When submitting for rendering, call this function to send the processed audio data back to the SDK so that the SDK can use it as an echo cancellation reference.
/// Use cases：In entertainment scenarios, it may be necessary to customize the processing of PCM audio data from the remote end, such as synthesizing a background sound and KTV accompaniment before rendering and playing. At the same time, developers are required to send the audio data processed by themselves to the SDK for reference, so that the processed sound effects can be echo canceled after collection.
/// When to call：After calling [fetchCustomAudioRenderPCMData] to fetch and process the PCM audio data, this function is called while submitting to the system for rendering and playback.
/// Restrictions：You must call [setEngineConfig] to enable the external audio data as a reference for this function to take effect. If you need to get the use of the function or the details, please consult ZEGO technical support.
///
/// @param data PCM buffer data
/// @param dataLength The total length of the buffer data
/// @param param The param of this PCM audio frame
- (void)sendReferenceAudioPCMData:(unsigned char *)data
                       dataLength:(unsigned int)dataLength
                            param:(ZGFlutterAudioFrameParam *)param;

@end

NS_ASSUME_NONNULL_END

#endif /* ZegoCustomAudioCaptureManager_h */
