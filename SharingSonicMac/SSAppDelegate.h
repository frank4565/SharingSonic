//
//  SSAppDelegate.h
//  SharingSonicMac
//
//  Created by Cheng Junlu on 4/9/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkHelper.h"

#import <QuartzCore/QuartzCore.h>
#import "BasicParameters.h"
#import "SoundGenerator.h"
#import "SoundReceiver.h"

@class SSStatusBarController;

@interface SSAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) SSStatusBarController *statusVC;

@end
