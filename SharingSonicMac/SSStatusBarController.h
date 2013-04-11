//
//  SSStatusBarControllerViewController.h
//  SharingSonicMac
//
//  Created by Cheng Junlu on 1/16/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NetworkHelper.h"

#import <QuartzCore/QuartzCore.h>
#import "BasicParameters.h"
#import "SoundGenerator.h"
#import "SoundReceiver.h"

@interface SSStatusBarController: NSViewController <NSApplicationDelegate,NetworkHelperDelegate,SoundGeneratorDelegate,SoundReceiverDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *statusIcon;
@property (nonatomic, strong) NSString *hashString;


@property (nonatomic, weak) IBOutlet NSMenu *statusMenu;

@end
