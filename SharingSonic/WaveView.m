//
//  WaveView.m
//  MultimediaProject
//
//  Created by PowerQian on 11/22/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "WaveView.h"
#import "ANSampleInput.h"
#import <QuartzCore/QuartzCore.h>

@interface WaveView ()

@end

@implementation WaveView

- (void)setup
{
//    self.layer.borderColor = [UIColor cyanColor].CGColor;
//    self.layer.borderWidth = 0.5f;
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

-(CGPoint)translateValueToViewWithX:(CGFloat)x andY:(CGFloat)y
{
    CGPoint pointInView;
    pointInView.x = x;
    
    float absoluteY = pow(( 96 - fabsf(y) ) / 10, 7) ;
    float absoluteOffsetOfYInView = absoluteY * (self.bounds.size.height / 2) / pow((float)96 / (float)10, 7);
    
    
    if ( y > 70 ) {
        pointInView.y = self.bounds.size.height / 2;
    } else if ( y > 0 ) {
        pointInView.y = self.bounds.size.height / 2 - absoluteOffsetOfYInView ;
    } else if ( y == 0) {
        //no sample or maximum
        pointInView.y = self.bounds.origin.y;
    } else pointInView.y = self.bounds.size.height / 2 + absoluteOffsetOfYInView ;
    return pointInView;
}


#define CORNER_RADIUS 12.0
#define INCREMENT 0.5

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CORNER_RADIUS];
    [roundedRect addClip];
    
    UIBezierPath *wave = [[UIBezierPath alloc] init];
    
    self.isUpdatingUI = YES;
    
    CGFloat xAxesLeftBounds = self.bounds.origin.x + 2;
    CGFloat xAxesRightBounds = self.bounds.size.width - 2;
    CGFloat y = [self.dataSource yValueForX:xAxesLeftBounds inPixelValue:self.bounds.size.width forSender:self];
    CGPoint point = [self translateValueToViewWithX:xAxesLeftBounds andY:y];
    
//    CGContextBeginPath(context);
    [wave moveToPoint:CGPointMake(point.x, point.y)];
//    CGContextMoveToPoint(context, point.x,point.y);
    
    for (float i = (xAxesLeftBounds + INCREMENT); i <= (xAxesRightBounds - INCREMENT); i += INCREMENT) {
        CGFloat yInLoop = [self.dataSource yValueForX:i
                                         inPixelValue:self.bounds.size.width
                                            forSender:self];
        CGPoint pointOnView = [self translateValueToViewWithX:i
                                                         andY:yInLoop];
        if (pointOnView.x > self.bounds.size.width
            || pointOnView.x < self.bounds.origin.x
            || pointOnView.y > self.bounds.size.height
            || pointOnView. y < self.bounds.origin.y) {
//            TODO:
//            NSLog(@"Potential Bug Exists!! point.x:%f,point.y:%f", pointOnView.x,pointOnView.y);
//            assert(0);
            pointOnView.y = self.bounds.origin.y;
        }
        [wave addLineToPoint:CGPointMake(pointOnView.x,pointOnView.y)];
//        CGContextAddLineToPoint(context, pointOnView.x,pointOnView.y);
//        [[UIColor colorWithRed:250 green:231 blue:75 alpha:0.5] setStroke];
        [[UIColor orangeColor] setStroke];
//        [[UIColor redColor] setStroke];
    }
//    CGContextDrawPath(context, kCGPathStroke);
    [wave stroke];
    self.isUpdatingUI = NO;
}


@end
