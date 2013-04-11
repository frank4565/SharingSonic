//
//  ANSampleOutput.mm
//  SoundMaker
//
//  Created by Alex Nichol on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANSampleOutput.h"

@interface ANSampleOutput (Private)

- (void)queueToBuffer:(AudioQueueBufferRef)buffer;
- (void)configureChannelLayout;

@end

void ANSampleOutputBufferCallback (void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer);

@implementation ANSampleOutput


- (id)initWithSampleBuffer:(ANSampleBuffer *)buffer withSampleRate:(NSUInteger)rate {
    if ((self = [super init])) {
        // TODO: create sample buffer
        
        audioFormat.mFormatID = kAudioFormatLinearPCM;
        audioFormat.mChannelsPerFrame = 1;
        audioFormat.mBitsPerChannel = 8 * sizeof(Float32);
        audioFormat.mFramesPerPacket = 1;
        audioFormat.mSampleRate = rate;
        audioFormat.mBytesPerFrame = sizeof(Float32);
        audioFormat.mBytesPerPacket = sizeof(Float32);
        audioFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat;
        
#if TARGET_OS_IPHONE
        UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,sizeof(UInt32), &sessionCategory);
        UInt32 defaultToSpeaker = TRUE;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(defaultToSpeaker), &defaultToSpeaker);
#endif
        
        OSStatus status = AudioQueueNewOutput(&audioFormat, ANSampleOutputBufferCallback,
                                              (__bridge void *)self, CFRunLoopGetCurrent(),
                                              kCFRunLoopDefaultMode, 0, &audioQueue);
        if (status != noErr) {
            return nil;
        }
        
        self.framesPerBuffer = buffer.sampleCount;
        
        for (int i = 0; i < kOutputBufferCount; i++) {
            status = AudioQueueAllocateBuffer(audioQueue, sizeof(Float32) * self.framesPerBuffer, &buffers[i]);
            if (status != noErr) {
                for (int j = i - 1; j >= 0; j--) {
                    AudioQueueFreeBuffer(audioQueue, buffers[j]);
                }
                AudioQueueDispose(audioQueue, NO);
                return nil;
            }
        }
        
        self.sampleBuffer = buffer;
    }
    return self;
}

- (OSStatus)startPlayer {
    memcpy((void *)buffers[0]->mAudioData, (void *) self.sampleBuffer.samples, self.framesPerBuffer * audioFormat.mBytesPerFrame);
    buffers[0]->mAudioDataByteSize = self.framesPerBuffer * audioFormat.mBytesPerFrame;
    OSStatus status = AudioQueueEnqueueBuffer(audioQueue, buffers[0], 0, NULL);
    if (status != noErr) {
#if TARGET_OS_IPHONE
        NSLog(@"Error occurs: %ld",status);
#elif TARGET_IPHONE_SIMULATOR
        NSLog(@"Error occurs: %ld",status);
#else
        NSLog(@"Error occurs: %d",status);
#endif
    }
    AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
    return AudioQueueStart(audioQueue, NULL);
}

- (OSStatus)stopPlayer {
    return AudioQueueStop(audioQueue, YES);
}

@end

void ANSampleOutputBufferCallback (void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) {
    ANSampleOutput *output = (__bridge ANSampleOutput *)inUserData;
    [output.delegate sampleOutputDidStop:output];
}

