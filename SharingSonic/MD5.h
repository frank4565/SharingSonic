//
//  MD5.h
//  MultimediaProject
//
//  Created by PowerQian on 11/17/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface MD5 : NSObject

+ (id)defaultMD5;
- (NSString *)md5ForData:(NSData *)data;

@end
