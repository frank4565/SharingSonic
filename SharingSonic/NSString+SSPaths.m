//
//  NSString+SSPaths.m
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/16/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "NSString+SSPaths.h"

@implementation NSString (SSPaths)

+ (NSString *)downloadsPath
{
    static dispatch_once_t onceToken;
	static NSString *cachedPath;
    
	dispatch_once(&onceToken, ^{
		cachedPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) lastObject];
	});
    
	return cachedPath;
}

@end
