//
//  ANSampleInput.h
//  InputTest
//
//  Created by PowerQian on 11/19/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define kBufferCount 50

@protocol ANSampleInputDelegate <NSObject>

- (void)inputDidUpdateWithSamples:(Float32 *)samples;

@end

@interface ANSampleInput : NSObject {
    AudioStreamBasicDescription audioFormat;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef buffers[kBufferCount];
}

@property NSUInteger frequency;
@property NSUInteger sampleRate;
@property UInt32 framesPerBuffer;
@property BOOL isRunning;

@property (weak,nonatomic) id <ANSampleInputDelegate> delegate;

- (id)initWithSampleRate:(NSUInteger)rate bufferSampleCount:(NSUInteger)sampleNumber;

- (OSStatus)startRecording;
- (OSStatus)stopRecording;
- (OSStatus)pauseRecording;

@end
