//
//  SoundReceiver.h
//  MultimediaProject
//
//  Created by PowerQian on 1/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSampleInput.h"
#import "FrequencyAnalyzer.h"

@protocol SoundReceiverDelegate <NSObject>

- (void)didGetResult:(NSString *)resultHashString;

@optional
- (void)didGetSamples:(Float32 *)samples;
- (void)didDetectStartingPattern;
- (void)didDetectEndingPattern;
- (void)timeoutAndFailedToGetResult;

@end

@interface SoundReceiver : NSObject <ANSampleInputDelegate, FrequencyAnalyzerDelegate>

@property BOOL shouldAnalyze;

@property (strong, nonatomic) ANSampleInput *input;

@property (weak, nonatomic) id <SoundReceiverDelegate> delegate;

- (OSStatus)startRecording;
- (OSStatus)stopRecording;
- (OSStatus)pauseRecording;

+(SoundReceiver *)defaultReceiver;

@end
