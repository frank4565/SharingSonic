//
//  NSSonicData.h
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _NSSonicType
{
    SonicTypeText = 0,
    SonicTypePhoto = 1,
    SonicTypeIndicator = 1024
} NSSonicType;

@interface NSSonicData : NSObject

@property (readonly, nonatomic, strong) NSDate *date;
@property (readonly, nonatomic) NSSonicType type;
@property (readonly, nonatomic, strong) UIView *view;
@property (readonly, nonatomic) UIEdgeInsets insets;
@property (nonatomic, strong) UIImage *typeImage;
@property (readonly, nonatomic) UIImage *image;
@property (readonly, nonatomic) NSString *text;

- (id)initWithText:(NSString *)text date:(NSDate *)date type:(NSSonicType)type;
+ (id)dataWithText:(NSString *)text date:(NSDate *)date type:(NSSonicType)type;
- (id)initWithImage:(UIImage *)image date:(NSDate *)date type:(NSSonicType)type;
+ (id)dataWithImage:(UIImage *)image date:(NSDate *)date type:(NSSonicType)type;
- (id)initWithView:(UIView *)view date:(NSDate *)date type:(NSSonicType)type insets:(UIEdgeInsets)insets;
+ (id)dataWithView:(UIView *)view date:(NSDate *)date type:(NSSonicType)type insets:(UIEdgeInsets)insets;

@end
