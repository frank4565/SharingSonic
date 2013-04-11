//
//  ANSampleInput.m
//  InputTest
//
//  Created by PowerQian on 11/19/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "ANSampleInput.h"
#import "FrequencyAnalyzer.h"
#import "BasicParameters.h"

@interface ANSampleInput ()

//- (void)queueToBuffer:(AudioQueueBufferRef)buffer;

@end

@implementation ANSampleInput

- (id)initWithSampleRate:(NSUInteger)rate bufferSampleCount:(NSUInteger)sampleNumber
{
    if ((self = [super init])) {
        self.sampleRate = rate;
        
        audioFormat.mFormatID = kAudioFormatLinearPCM;
        audioFormat.mChannelsPerFrame = 1;
        audioFormat.mBitsPerChannel = 8 * sizeof(Float32);
        audioFormat.mFramesPerPacket = 1;
        audioFormat.mSampleRate = rate;
        audioFormat.mBytesPerFrame = sizeof(Float32);
        audioFormat.mBytesPerPacket = sizeof(Float32);
        audioFormat.mFormatFlags = kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat;
        
        
        OSStatus status = AudioQueueNewInput(&audioFormat, MyAudioQueueInputCallback,
                                             (void *)CFBridgingRetain(self), CFRunLoopGetCurrent(),
                                             kCFRunLoopCommonModes, 0, &audioQueue);
        if (status != noErr) {
            return nil;
        }
        
        self.framesPerBuffer = sampleNumber;
        
        for (int i = 0; i < kBufferCount; i++) {
            status = AudioQueueAllocateBuffer(audioQueue, sizeof(Float32) * self.framesPerBuffer, &buffers[i]);
            if (status != noErr) {
                for (int j = i - 1; j >= 0; j--) {
                    AudioQueueFreeBuffer(audioQueue, buffers[j]);
                }
                AudioQueueDispose(audioQueue, NO);
                return nil;
            }
            AudioQueueEnqueueBuffer(audioQueue, buffers[i], 0, NULL);
        }
    }
    return self;
}

- (OSStatus)startRecording
{
    self.isRunning = YES;
    
    return AudioQueueStart(audioQueue, NULL);
}

- (OSStatus)pauseRecording
{
    self.isRunning = NO;
    return AudioQueuePause(audioQueue);
}

- (OSStatus)stopRecording
{
    AudioQueueReset(audioQueue);
    OSStatus err = AudioQueueStop(audioQueue, YES);
    AudioQueueDispose(audioQueue, YES);
    self.isRunning = NO;
    return err;
}

//- (void)queueToBuffer:(AudioQueueBufferRef)buffer {
//    NSLog(@"Buffer: %p", buffer);
//    
//    Float32 * samples = (Float32 *)buffer->mAudioData;
//    Float32 * data = malloc(self.framesPerBuffer * sizeof(Float32));
//    memcpy(data, samples, self.framesPerBuffer * audioFormat.mBytesPerFrame);
////    AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL);
//    
//    OSStatus status = AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL);
//    NSLog(@"%ld",status);
//    
////    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[FrequencyAnalyzer defaultAnalyzer] startFrequencyAnalyzeWithSamples:data];
//    });
//}



void MyAudioQueueInputCallback (
                                void                                *inUserData,
                                AudioQueueRef                       inAQ,
                                AudioQueueBufferRef                 inBuffer,
                                const AudioTimeStamp                *inStartTime,
                                UInt32                              inNumberPacketDescriptions,
                                const AudioStreamPacketDescription  *inPacketDescs
                                )
{
    ANSampleInput *input = (__bridge ANSampleInput *)inUserData;

    Float32 * samples = (Float32 *)inBuffer->mAudioData;
    Float32 * data = malloc(input.framesPerBuffer * sizeof(Float32 *));
    memcpy(data, samples, input.framesPerBuffer * input->audioFormat.mBytesPerFrame );
    AudioQueueEnqueueBuffer(input->audioQueue, inBuffer, 0, NULL);
//    if (status != noErr) NSLog(@"Error!!! Error code:%ld",status);
    
//    for (int i = 0; i < SINGLE_BUFFER_SAMPLE_COUNT; i++) {
//        printf("%f",data[i]);
//    }
    
    [input.delegate inputDidUpdateWithSamples:data];
}

@end
