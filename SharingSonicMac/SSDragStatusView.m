//
//  SSDragStatusView.m
//  SharingSonicMac
//
//  Created by Cheng Junlu on 2/4/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSDragStatusView.h"

@implementation SSDragStatusView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //register for drags
//        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
        [self registerForDraggedTypes:@[NSURLPboardType]];

        _isMenuVisible = NO;
        self.statusItem = nil;
    }
    
    return self;
}

static const int StatusItemViewPaddingWidth = 1;
static const int StatusItemViewPaddingHeight = 0;

- (void)drawRect:(NSRect)rect
{
    // Draw status bar background, highlighted if menu is showing    
    [self.statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:_isMenuVisible];
    // Draw status bar foreground image
    NSPoint origin = NSMakePoint(StatusItemViewPaddingWidth,
                                 StatusItemViewPaddingHeight);
    [self.image drawAtPoint:origin fromRect:[self bounds] operation:NSCompositeSourceOver fraction:1.0];
}

#pragma mark - Handling Mouse Clicks

- (void)mouseDown:(NSEvent *)theEvent
{
    [[self menu] setDelegate:self];
    [self.statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

#pragma mark - Handling Menu Pops

- (void)menuWillOpen:(NSMenu *)menu
{
    _isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu
{
    _isMenuVisible = NO;
    [menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

#pragma mark - Destination Operations

//we want to copy the files
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //Ivoke this method explicitly for drag and drop from Dock folder.
    //A weird way.
    [self performDragOperation:sender];
}

//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSURLPboardType] ) {
//        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSLog(@"Drag a file: %@",fileURL);
        [self.delegate dragAndDropFile:fileURL];
    }
    return YES;
}





@end
