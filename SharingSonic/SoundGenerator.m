//
//  SoundGenerator.m
//  MultimediaProject
//
//  Created by PowerQian on 1/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SoundGenerator.h"
#import "NoteDictionary.h"

@interface SoundGenerator()
//@property (strong,nonatomic) ANSampleOutput * sampleOutput;
//@property (strong,nonatomic) ANSampleBuffer * sampleBuffer;
@property (strong, nonatomic) NSDictionary *noteDictionary;
@property (strong, nonatomic) ANSampleOutput *currentOutput;
@end

@implementation SoundGenerator

#pragma * Lazy initializer
- (NSDictionary *)noteDictionary
{
    if (!_noteDictionary) {
        _noteDictionary = [[NoteDictionary defaultDictionary] noteDictionaryForHash];
    }
    return _noteDictionary;
}

- (OSStatus)generateSoundOfHashString:(NSString *)hashString
{
    //add starting and ending pattern
    NSString *hashStringToSend = [NSString stringWithFormat:@"xy%@yx",hashString];
    
    NSUInteger repeatTimes = [hashStringToSend length];
    
    double totalDuration = repeatTimes * SINGLE_NOTE_DURATION;
    
    ANSampleBuffer *sampleBuffer = [[ANSampleBuffer alloc] initWithSampleCount:totalDuration * SAMPLE_RATE rate:SAMPLE_RATE];
    [sampleBuffer setOffset:0];
    
    for (int i = 0; i < repeatTimes ; i++) {
        [sampleBuffer appendSamplesForTime:SINGLE_NOTE_DURATION
                             withFrequency:[[[NoteDictionary defaultDictionary].noteDictionaryForHash objectForKey:[NSString stringWithFormat:@"%c",[hashStringToSend characterAtIndex:i]]] floatValue]];
    }
    
    ANSampleOutput *sampleOutput = [[ANSampleOutput alloc] initWithSampleBuffer:sampleBuffer withSampleRate:SAMPLE_RATE];
    sampleOutput.delegate = self;
    self.currentOutput = sampleOutput;
    
    if ([self.delegate respondsToSelector:@selector(soundGeneratingWillStart)]) {
        [self.delegate soundGeneratingWillStart];
    }
    
    self.isSending = YES;
    OSStatus err = [sampleOutput startPlayer];
    if (err == noErr) {
        if ([self.delegate respondsToSelector:@selector(soundGeneratingDidStart)]) {
            [self.delegate soundGeneratingDidStart];
        }
        return noErr;
    } else {
        //Something goes wrong
        return err;
    }
}

- (OSStatus)stopSound
{
    return [self.currentOutput stopPlayer];
}


#pragma mark ANSampleOutputDelegate
- (void)sampleOutputDidStop:(ANSampleOutput *)sampleOutput
{
    [sampleOutput stopPlayer];
    self.isSending = NO;
    if ([self.delegate respondsToSelector:@selector(soundGeneratingDidStop)]) {
        [self.delegate soundGeneratingDidStop];
    }
}

//Singleton using GCD
+ (SoundGenerator *)defaultGenerator
{
    static SoundGenerator *defaultSoundGenerator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultSoundGenerator = [[self alloc] init];
    });
    return defaultSoundGenerator;
}
//
@end
