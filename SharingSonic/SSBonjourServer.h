//
//  SSBonjourServer.h
//  SharingSonicMac
//
//  Created by Cheng Junlu on 2/28/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "DTBonjourServer.h"

const static NSString *kIDENTIFIER = @"SSID";

@interface SSBonjourServer : DTBonjourServer

- (id)initWithNone;

@property (nonatomic, readonly) NSString *identifier;

@end
