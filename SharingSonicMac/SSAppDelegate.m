//
//  SSAppDelegate.m
//  SharingSonicMac
//
//  Created by Cheng Junlu on 4/9/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSAppDelegate.h"
#import "SSStatusBarController.h"

@interface SSAppDelegate ()
//@property (strong) NSMutableArray *sonicData;
//@property (assign) Float32 *sampleData;
@property (nonatomic, strong) NSArray *serverArray;
@property (nonatomic, strong) NSMutableArray *clients;
@end

@implementation SSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (!self.statusVC) {
        self.statusVC = [[SSStatusBarController alloc] initWithNibName:@"SSStatusBarController" bundle:[NSBundle mainBundle]];
    }
}

@end
