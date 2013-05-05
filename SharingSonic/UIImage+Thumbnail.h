//
//  UIImage+Thumbnail.h
//  SharingSonic
//
//  Created by Cheng Junlu on 5/5/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Thumbnail)

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;

@end
