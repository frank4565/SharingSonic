//
//  SSBonjour.h
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/7/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SSBonjourServer.h"
#import "NetworkHelper.h"

@interface SSBonjour : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *foundServices;
@property (nonatomic, weak) id<NetworkHelperDelegate> delegate;

- (id)initWithNone;
- (void)sendFile:(NSString *)filePath;
- (void)sendFile:(NSString *)filePath toServices:(NSNetService *)service;

@end
