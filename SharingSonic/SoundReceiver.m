//
//  SoundReceiver.m
//  MultimediaProject
//
//  Created by PowerQian on 1/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SoundReceiver.h"
#import "BasicParameters.h"

@interface SoundReceiver () 

@property NSUInteger sameFreqCount;
@property BOOL isDetected;
@property BOOL isAnalyzed;
@property (strong,nonatomic) NSDate *startTime;

@property (strong,nonatomic) NSMutableArray *freqCharArray;
@property (strong,nonatomic) NSMutableArray *detectedHashStringArray;
@property (strong,nonatomic) NSMutableString *analyzedString;

@property (nonatomic) float meanFreq;

@end

@implementation SoundReceiver

#pragma mark Lazy Initializer
- (NSMutableArray *)freqCharArray
{
    if (!_freqCharArray) {
        _freqCharArray = [[NSMutableArray alloc] init];
    }
    return _freqCharArray;
}
- (NSMutableArray *)detectedHashStringArray
{
    if (!_detectedHashStringArray) {
        _detectedHashStringArray = [[NSMutableArray alloc] init];
    }
    return _detectedHashStringArray;
}

#pragma mark Core Function



static int const MD5_LEN = 32;

- (void)_finishAnalyze
{
    // Have found the end pattern or time expired.
    if ([self.delegate respondsToSelector:@selector(didDetectEndingPattern)]) {
        [self.delegate didDetectEndingPattern];
    }
    
    self.isAnalyzed = YES;
    self.isDetected = NO;
    self.analyzedString = [NSMutableString stringWithCapacity:[self.detectedHashStringArray count]];
    for (int i = 0; i < [self.detectedHashStringArray count]; i++) {
        //remove the starting and ending pattern character.
        //Actually, there shouldn't be y as the starting pattern wasn't added to self.detectedHashStringArray.
        if (!([self.detectedHashStringArray[i] isEqualToString:@"x"] || [self.detectedHashStringArray[i] isEqualToString:@"y"]) ) {
            [self.analyzedString appendString:self.detectedHashStringArray[i]];
        }
    }
    NSLog(@"Analyzed String:%@",self.analyzedString);
    NSString *finalResult = self.analyzedString;
    
    //do some cleaning.
    [self.freqCharArray removeAllObjects];
    [self.detectedHashStringArray removeAllObjects];
    self.analyzedString = nil;
    
    if (MD5_LEN / 2 < [finalResult length]) {
        [self.delegate didGetResult:finalResult];
    }
}

- (void)_addChar
{
    NSString *freqChar;
    freqChar = [[FrequencyAnalyzer defaultAnalyzer] findCharacterForFreq:self.meanFreq];
    
    if (freqChar) {
        [self.freqCharArray addObject:freqChar];
        if (self.isDetected) {
            [self.detectedHashStringArray addObject:freqChar];
        }
        
        // Determine the starting pattern and ending pattern
        if ([self.freqCharArray count] > 1) {
            NSString *lastChar = [self.freqCharArray lastObject];
            if ([lastChar isEqualToString:@"y"]) {
                //start pattern found
                NSLog(@"Start Pattern Found!");
                if ([self.delegate respondsToSelector:@selector(didDetectStartingPattern)]) {
                    [self.delegate didDetectStartingPattern];
                }
                self.isDetected = YES;
                self.isAnalyzed = NO;
                self.startTime = [NSDate date];
            } else if (self.isDetected && [[self.freqCharArray lastObject] isEqualToString:@"x"]) {
                //ending pattern found
                NSLog(@"Ending Pattern Found!");
                [self _finishAnalyze];
            }
        }
    }
}

#pragma mark FrequencyAnalyzerDelegate

static int const MAX_SAME_FREQUENCY_COUNT = 8; // SINGLE_NOTE_DURATION * SAMPLE_RATE / SINGLE_BUFFER_SAMPLE_COUNT
static int const MAX_SOUND_DURATION = 2;

- (BOOL)isFrequency:(float)f1 EqualToFrequency:(float)f2
{
    return ABS( f1 - f2 ) < 200;
}

- (void)updateMeanFrequencyWith:(float)freq
{
    self.meanFreq = (self.meanFreq * self.sameFreqCount + freq) / (float)(++self.sameFreqCount);
}

- (void)analyzeDidFinishWithResultFrequency:(float)freq
{
    // Ready to change sample size to 256 or smaller.
    //
    //
    //
    //The freq means the frequency of the analyzed sample array.
    //
    //Every duration of a single character is 0.05 sec.
    //Every array of sample count is 512, which is 512 / 44100 = about 0.011 sec.
    //These parameters are defined in BasicParameters.h.
    //So I have to check for continueously 4 sample array with same frequent(freqDiff<200)
    //and consider it as a character.
    //
    //However there would be some note has only one samples somehow, those frequency
    //also need to find the corresponding character, because in the find character
    //process if the character of frequency can not be found, it will return nil.
    //More details in find character part
    
    
    //if it is triggered and no ending pattern
    if (self.isDetected == YES && [[NSDate date] timeIntervalSinceDate:self.startTime] > MAX_SOUND_DURATION ) {
        [self _finishAnalyze];
    }
    
    // NSLog(@"%f, %f", self.meanFreq, freq);
    
    if (freq > MIN_FREQ_IN_USE) {
        if ([self isFrequency:self.meanFreq EqualToFrequency:freq]) {
            if (self.sameFreqCount > 1 && self.sameFreqCount <= MAX_SAME_FREQUENCY_COUNT) {
                //find the average frequency of the frequencies analyzed.
                [self updateMeanFrequencyWith:freq];
                //if there are more than 4 same frequecies.
                if (self.sameFreqCount > MAX_SAME_FREQUENCY_COUNT) {
                    // NSLog(@"1 the sameFreqCount is %d.", self.sameFreqCount);
                    [self _addChar];
                    self.sameFreqCount = 0;
                }
            } else if (self.sameFreqCount == 0) {
                self.sameFreqCount++;
                [self updateMeanFrequencyWith:freq];
                // NSLog(@"2 the sameFreqCount is %d.", self.sameFreqCount);
            } else {
#if TARGET_OS_IPHONE
                NSLog(@"ERROR of sameFreqCount:%d.", self.sameFreqCount);
#elif TARGET_IPHONE_SIMULATOR
                NSLog(@"ERROR of sameFreqCount:%d.", self.sameFreqCount);
#else
                NSLog(@"ERROR of sameFreqCount:%ld.", self.sameFreqCount);
#endif
            }
        } else {
            // NSLog(@"3 the sameFreqCount is %d.", self.sameFreqCount);
            if (self.sameFreqCount > 1) {
                [self _addChar];
            }
            self.meanFreq = freq;
            self.sameFreqCount = 0;
        }
    }
}

#pragma mark ANSampleInputDelegate
- (void)inputDidUpdateWithSamples:(Float32 *)samples
{
    if ([self.delegate respondsToSelector:@selector(didGetSamples:)]) {
        [self.delegate didGetSamples:samples];
    }
    [FrequencyAnalyzer defaultAnalyzer].delegate = self;
    if (self.shouldAnalyze) {
        [[FrequencyAnalyzer defaultAnalyzer] startFrequencyAnalyzeWithSamples:samples];
    }
    //the sample array is alloced in the Callback of ANSampleInput
    free(samples);
}

#pragma Member Method
- (OSStatus)startRecording
{
    if (!self.input) {
        self.input = [[ANSampleInput alloc] initWithSampleRate:SAMPLE_RATE bufferSampleCount:SINGLE_BUFFER_SAMPLE_COUNT];
        self.input.delegate = self;
    }
    return [self.input startRecording];
}

- (OSStatus)stopRecording
{
    //*************************
    //**********Caution********
    //*************************
    //Since stopRecording in ANSampleInput calls AudioQueueDispose,
    //after calling this method, we cannot interact with audio queue
    //anymore. Not sure whether should call AudioQueueDispose.
    
    return [self.input stopRecording];
}

- (OSStatus)pauseRecording
{
    return [self.input pauseRecording];
}


//Singleton using GCD
+(SoundReceiver *)defaultReceiver
{
    static SoundReceiver *defaultSoundReceiver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultSoundReceiver = [[self alloc] init];
    });
    return defaultSoundReceiver;
}
//
@end
