//
//  FrequencyAnalyzer.h
//  InputTest
//
//  Created by PowerQian on 11/20/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FrequencyAnalyzerDelegate <NSObject>

- (void)analyzeDidFinishWithResultFrequency:(float)freq;

@end

@interface FrequencyAnalyzer : NSObject

- (void)startFrequencyAnalyzeWithSamples:(Float32 *)samples;
- (NSString *)findCharacterForFreq:(float)freq;

@property (weak,nonatomic) id <FrequencyAnalyzerDelegate> delegate;

+ (FrequencyAnalyzer *) defaultAnalyzer;

@end
