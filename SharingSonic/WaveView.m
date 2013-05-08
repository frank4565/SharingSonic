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
    // Any additional initializations
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

- (Float32)_translateIntodBValue:(Float32)value
{
    Float32 returnValue = 0;
    if (value > 0) {
        returnValue = 10 * log10f(value);
    } else if (value < 0) {
        returnValue = -10 * log10f(-value);
    } else if (value == 0) {
        //        TODO
        //        NSLog(@"Sample Value = 0");
        returnValue = 96;
    }
    return returnValue;
}

-(CGPoint)translateValueToViewWithX:(CGFloat)x andY:(CGFloat)y
{
    CGPoint pointInView;
    pointInView.x = x;

    float dbY = [self _translateIntodBValue:y];

    float absoluteY = pow(( 96 - fabsf(dbY) ) / 10, 7) ;
    float absoluteOffsetOfYInView = absoluteY * (self.bounds.size.height / 2) / pow((float)96 / (float)10, 7);
    
    if ( y > 70 || y == 0) {
        pointInView.y = self.bounds.size.height / 2;
    } else if ( y > 0 ) {
        pointInView.y = self.bounds.size.height / 2 - absoluteOffsetOfYInView ;
    } else
        pointInView.y = self.bounds.size.height / 2 + absoluteOffsetOfYInView ;
    
    return pointInView;
}

- (CGFloat)_cosineInterpolationWithFirstY:(CGFloat)y1 Second:(CGFloat)y2 xLocation:(double)x
{
    double x2 = (1 - cosf(x * M_PI)) / 2;
    
    return (y1 * ( 1 - x2 ) + y2 * x2);
}


#define CORNER_RADIUS 12.0
#define INCREMENT 0.5
//#define ACTUAL_POINTS_NUMBER 50
static NSUInteger const ACTUAL_POINTS_NUMBER = 100;

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSArray *ys = [self.dataSource waveView:self getYValueOfNumber:ACTUAL_POINTS_NUMBER];
    if (ys) {
        UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CORNER_RADIUS];
        [roundedRect addClip];
        
        UIBezierPath *wave = [[UIBezierPath alloc] init];
        
        self.isUpdatingUI = YES;
        
        CGFloat xAxesLeftBounds = self.bounds.origin.x;
        CGFloat xAxesRightBounds = self.bounds.size.width;
        
//        CGFloat y = [self.dataSource yValueForX:xAxesLeftBounds inPixelValue:self.bounds.size.width forSender:self];
//        CGPoint point = [self translateValueToViewWithX:xAxesLeftBounds andY:y];
        
        //    CGContextBeginPath(context);
        [wave moveToPoint:CGPointMake(self.bounds.origin.x, self.bounds.size.height / 2)];
        //    CGContextMoveToPoint(context, point.x,point.y);
        
        for (float i = xAxesLeftBounds + INCREMENT; i <= xAxesRightBounds - INCREMENT; i += INCREMENT) {
            //        CGFloat yInLoop = [self.dataSource yValueForX:i
            //                                         inPixelValue:self.bounds.size.width
            //                                            forSender:self];
            CGFloat range = xAxesRightBounds - xAxesLeftBounds - INCREMENT * 2;
            NSUInteger yNumber = floorf(i * ACTUAL_POINTS_NUMBER / range);
            float decimalPlace = i * ACTUAL_POINTS_NUMBER / range - yNumber;
            CGFloat firstY = 0;
            CGFloat secondY = 0;
            if (yNumber < ACTUAL_POINTS_NUMBER) {
                firstY = [ys[yNumber] floatValue];
            }
            if (yNumber + 1 < ACTUAL_POINTS_NUMBER) {
                secondY = [ys[yNumber + 1] floatValue];
            }
            CGFloat yInLoop = [self _cosineInterpolationWithFirstY:firstY Second:secondY xLocation:decimalPlace];
            
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
}


@end
