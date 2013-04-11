//
//  SSBonjourData.h
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSBonjourData : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, strong, readonly) NSString *filePath;

- (id)initWithData:(NSData *)data;
- (id)initWithFile:(NSString *)filePath;

@end
