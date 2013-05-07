//
//  UIImage+Thumbnail.m
//  SharingSonic
//
//  Created by Cheng Junlu on 5/5/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "UIImage+Thumbnail.h"

@implementation UIImage (Thumbnail)

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, 140.0f, 120.0f);
    [[UIColor blackColor] set];
    
//    CGFloat *actualFontSize = NULL;
//    [text sizeWithFont:font minFontSize:12.0f actualFontSize:actualFontSize forWidth:140.0f lineBreakMode:NSLineBreakByTruncatingMiddle];
    
    [text drawInRect:CGRectIntegral(rect) withFont:font lineBreakMode:NSLineBreakByTruncatingMiddle];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
