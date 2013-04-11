//
//  SoundGenerator.h
//  MultimediaProject
//
//  Created by PowerQian on 1/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSampleOutput.h"
#import "BasicParameters.h"

@protocol SoundGeneratorDelegate <NSObject>

@optional
- (void)soundGeneratingWillStart;
- (void)soundGeneratingDidStart;
- (void)soundGeneratingDidStop;

@end

@interface SoundGenerator : NSObject <ANSampleOutputDelegate>

//@property double frequency;
@property (nonatomic) BOOL isSending;

@property (weak, nonatomic) id <SoundGeneratorDelegate> delegate;

- (OSStatus)generateSoundOfHashString:(NSString *)hashString;
- (OSStatus)stopSound;

+ (SoundGenerator *)defaultGenerator;

@end
