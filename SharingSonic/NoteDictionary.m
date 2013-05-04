//
//  NoteDictionary.m
//  MultimediaProject
//
//  Created by PowerQian on 11/15/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "NoteDictionary.h"

@interface NoteDictionary()


@end

@implementation NoteDictionary

- (NSDictionary *)noteDictionaryForHash
{
    if (!_noteDictionaryForHash) {
        _noteDictionaryForHash =
        @{
        @"a" : @7400.00f,
        @"b" : @7840.00f,
        @"c" : @8280.00f,
        @"d" : @8720.00f,
        @"e" : @9160.00f,
        @"f" : @9600.00f,
        @"0" : @3000.00f,
        @"1" : @3440.00f,
        @"2" : @3880.00f,
        @"3" : @4320.00f,
        @"4" : @4760.00f,
        @"5" : @5200.00f,
        @"6" : @5640.00f,
        @"7" : @6080.00f,
        @"8" : @6520.00f,
        @"9" : @6960.00f,
        @"x" : @2000.00f,
        @"y" : @10000.00f
        };
    }
    
    return _noteDictionaryForHash;
}

+ (NoteDictionary *)defaultDictionary
{
    static NoteDictionary *defaultNoteDictionaryClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultNoteDictionaryClass = [[self alloc] init];
    });
    return defaultNoteDictionaryClass;
}

@end
