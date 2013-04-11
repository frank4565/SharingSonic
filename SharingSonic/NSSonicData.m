//
//  NSSonicData.m
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "NSSonicData.h"
#import <QuartzCore/QuartzCore.h>

@implementation NSSonicData
//Auto Synthesised


//General content insets, which is the insets of content in a bubble to the bubble's outline.
//This should be treated differently with different content type.

const UIEdgeInsets insets = {18, 18, 18, 18};

#pragma mark - Text bubble

//const UIEdgeInsets textInsets = {5, 10, 11, 17};  //Need to be considered more carefully

+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSSonicType)type
{
    return [[NSSonicData alloc] initWithText:text date:date type:type];
}

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSSonicType)type
{
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    CGSize size = [(text ? text : @"") sizeWithFont:font constrainedToSize:CGSizeMake(220, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = (text ? text : @"");
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    _text = text;
    
    //    UIEdgeInsets insets = textInsets;
    return [self initWithView:label date:date type:type insets:insets];
}

#pragma mark - Image bubble
//Need to be considered more.
const UIEdgeInsets imageInsets = {11, 13, 16, 22};

+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSSonicType)type
{
    return [[NSSonicData alloc] initWithImage:image date:date type:type];
}

- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSSonicType)type
{
    //Here is the place to deal with image in an entity.
    
    CGSize size = image.size;
    if (size.width > 220)
    {
        size.height /= (size.width / 220);
        size.width = 220;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = image;
    imageView.layer.cornerRadius = 5.0;
    imageView.layer.masksToBounds = YES;
    
    _image = image;
    
    //    UIEdgeInsets imageInsets;
    return [self initWithView:imageView date:date type:type insets:insets];
}

#pragma mark - Custom view bubble

+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSSonicType)type insets:(UIEdgeInsets)insets
{
    return [[NSSonicData alloc] initWithView:view date:date type:type insets:insets];
}

- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSSonicType)type insets:(UIEdgeInsets)insets
{
    self = [super init];
    if (self)
    {
        _view = view;
        _date = date;
        _type = type;
        _insets = insets;
    }
    return self;
}



@end
