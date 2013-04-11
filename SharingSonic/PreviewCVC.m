//
//  PreviewCVC.m
//  MultimediaProject
//
//  Created by PowerQian on 2/23/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "PreviewCVC.h"

@interface PreviewCVC ()
@end

@implementation PreviewCVC

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

#define UNDERLINE_ANIMATION_DURATION 0.2

- (void)setIsSelected:(BOOL)isSelected
{
    if (isSelected) {
        [UIView transitionWithView:self
                          duration:UNDERLINE_ANIMATION_DURATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.underlineImageView.image = [UIImage imageNamed:@"underline2.png"];
                        }
                        completion:nil];
    } else {
        [UIView transitionWithView:self
                          duration:UNDERLINE_ANIMATION_DURATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.underlineImageView.image = nil;
                        }
                        completion:nil];
    }
}

//-(UIImage *)imageFromText:(NSString *)text font:(UIFont *)font
//{
//    // set the font type and size
////    UIFont *font = [UIFont systemFontOfSize:20.0];
//    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(55, 9999) lineBreakMode:NSLineBreakByWordWrapping];
////    CGSize size  = [text sizeWithFont:font];
//    
//    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
//    if (UIGraphicsBeginImageContextWithOptions != NULL)
//        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
//    else
//        // iOS is < 4.0
//        UIGraphicsBeginImageContext(size);
//    
//    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
//    //
//    // CGContextRef ctx = UIGraphicsGetCurrentContext();
//    // CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
//    
//    // draw in context, you can use also drawInRect:withFont:
//    [text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
//    
//    // transfer image
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}

- (UIImage *)textImage
{
    return [UIImage imageNamed:@"text-image.png"];
}

@end
