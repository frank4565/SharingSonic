//
//  SonicHeaderTableViewCell.m
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "SonicHeaderTableViewCell.h"

@interface SonicHeaderTableViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation SonicHeaderTableViewCell

+ (CGFloat)height
{
    return 25.0;
}

- (void)setDate:(NSDate *)value
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *text = [dateFormatter stringFromDate:value];
    
    if (self.label)
    {
        self.label.text = text;
        return;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [SonicHeaderTableViewCell height])];
    self.label.text = text;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.shadowOffset = CGSizeMake(0, 1);
    self.label.shadowColor = [UIColor whiteColor];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

@end
