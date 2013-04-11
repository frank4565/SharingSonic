//
//  MD5.m
//  MultimediaProject
//
//  Created by PowerQian on 11/17/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "MD5.h"

@implementation MD5

static id defaultMD5 = nil;

+ (void)initialize {
    if (self == [MD5 class]) {
        defaultMD5 = [[self alloc] init];
    }
}

+ (id)defaultMD5 {
    return defaultMD5;
}

- (NSString *)md5ForData:(NSData *)data
{
//    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( data.bytes, (unsigned int) data.length, digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end



