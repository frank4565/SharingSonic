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

//@property (nonatomic, strong, readonly) NSMutableArray *createdClients;
//@property (nonatomic, strong, readonly) SSBonjourServer *server;
//@property (nonatomic, strong, readonly) NSNetServiceBrowser *serviceBrowser;
//@property (nonatomic, strong, readonly) NSMutableSet *unidentifiedServices;
@property (nonatomic, strong, readonly) NSMutableArray *foundServices;
//@property (nonatomic, strong, readonly) NSMutableArray *createdServers;
@property (nonatomic, weak) id<NetworkHelperDelegate> delegate;

- (id)initWithNone;
- (void)sendFile:(NSString *)filePath;

@end
