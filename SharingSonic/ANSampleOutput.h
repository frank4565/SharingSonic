//
//  ANSampleOutput.h
//  SoundMaker
//
//  Created by Alex Nichol on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "ANSampleBuffer.h"
#import "ANSineWaveGenerator.h"

#define kOutputBufferCount 1

@class ANSampleOutput;

@protocol ANSampleOutputDelegate <NSObject>

- (void)sampleOutputDidStop:(ANSampleOutput *)sampleOutput;

@end

@interface ANSampleOutput : NSObject {
    AudioStreamBasicDescription audioFormat;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef buffers[kOutputBufferCount];
}

@property (strong,nonatomic) ANSampleBuffer * sampleBuffer;
@property NSUInteger frequency;
@property NSUInteger sampleRate;
@property UInt32 framesPerBuffer;

@property (strong,nonatomic) id <ANSampleOutputDelegate> delegate;

- (id)initWithSampleBuffer:(ANSampleBuffer *)buffer withSampleRate:(NSUInteger)rate;

- (OSStatus)startPlayer;
- (OSStatus)stopPlayer;

@end
