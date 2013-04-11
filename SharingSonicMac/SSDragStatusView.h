//
//  SSDragStatusView.h
//  SharingSonicMac
//
//  Created by Cheng Junlu on 2/4/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SSDragStatusViewDelegate <NSObject>

- (void)dragAndDropFile:(NSURL *)fileURL;

@end

@interface SSDragStatusView : NSImageView <NSDraggingDestination, NSMenuDelegate>
{
    BOOL _isMenuVisible;
}

@property (nonatomic, weak) NSStatusItem *statusItem;

@property (nonatomic, weak) id<SSDragStatusViewDelegate> delegate;


@end
