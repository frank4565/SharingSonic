//
//  ANSampleBuffer.m
//  SoundMaker
//
//  Created by Alex Nichol on 2/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANSampleBuffer.h"

@implementation ANSampleBuffer

@synthesize samples;
@synthesize sampleCount;
@synthesize sampleRate;
@synthesize offset;

- (id)initWithSampleCount:(NSUInteger)count rate:(NSUInteger)rate {
    if ((self = [super init])) {
        samples = (Float32 *)malloc(sizeof(Float32) * count);
        sampleCount = count;
        sampleRate = rate;
    }
    return self;
}

- (void)appendSamples:(NSUInteger)count withFrequency:(NSInteger)frequency {
    if (count + offset > sampleCount) {
        count = sampleCount - offset;
    }
    Float32 currentTime = 0;
    for (int i = 0 ; i < count; i++) {
        currentTime = (Float32)i / (Float32)sampleRate;
        samples[i+offset] = sinf(2 * M_PI * (Float32)frequency * currentTime );
    }
    offset += count;
}

- (void)appendSamplesForTime:(NSTimeInterval)time withFrequency:(NSInteger)frequency {
    NSUInteger count = round(time * (double)sampleRate);
    [self appendSamples:count withFrequency:frequency];
}


- (void)dealloc {
    free(samples);
}

@end
