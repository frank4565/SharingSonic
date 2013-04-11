//
//  UIButtonWithLargerTapArea.m
//  MultimediaProject
//
//  Created by PowerQian on 12/26/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "UIButtonWithLargerTapArea.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIButtonWithLargerTapArea

#define CORNER_RADIUS_OF_BUTTON 4.0

- (void)setup
{
//    self.layer.cornerRadius = CORNER_RADIUS_OF_BUTTON;
//    self.layer.masksToBounds = YES;
}

- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect largerTapBounds;
    CGFloat widthDelta = 44.0 - self.bounds.size.width;
    CGFloat heightDelta = 44.0 - self.bounds.size.height;
    largerTapBounds = CGRectInset(self.bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(largerTapBounds, point);
}

@end
