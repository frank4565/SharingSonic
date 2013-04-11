//
//  SonicTableViewCell.m
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "SonicTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface SonicTableViewCell ()

@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) UIImageView *bubbleImage;
@property (nonatomic, retain) UIImageView *typeImage;

- (void) setupInternalData;

@end

@implementation SonicTableViewCell
//Auto Synthesised

- (void)_copyToPasteboard:(id)sender {
    // called when copy clicked in menu
    [UIPasteboard generalPasteboard].string = self.data.text;
}

- (void)_handleDetailAction:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        if (self.data.type == SonicTypePhoto) {
            [self.delegate tappedOnPhotoWithImage:self.data.image];
        } else if (self.data.type == SonicTypeText) {
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(_copyToPasteboard:)];
            CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];

            [self becomeFirstResponder];
            [menuController setMenuItems:[NSArray arrayWithObject:copyMenuItem]];
            [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

//Used for UIMenuController
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(_copyToPasteboard:))
        return YES;
    else return NO;
}
//

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDetailAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}

- (void)setDataInternal:(NSSonicData *)value
{
	self.data = value;
	[self setupInternalData];
}

- (void) setupInternalData
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!self.bubbleImage)
    {
        self.bubbleImage = [[UIImageView alloc] init];
        [self addSubview:self.bubbleImage];
    }
    
    //For future use
    NSSonicType type = self.data.type;
    

    
    // Adjusting the x coordinate for avatar
    [self.typeImage removeFromSuperview];
    switch (type) {
        case SonicTypePhoto:
            self.typeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Photo.png"]];
            break;
        case SonicTypeText:
            self.typeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Pencil.png"]];
        default:
            break;
    }
    self.typeImage.layer.cornerRadius = 3.0;
    self.typeImage.layer.masksToBounds = YES;
    self.typeImage.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.2].CGColor;
    self.typeImage.layer.backgroundColor = [UIColor grayColor].CGColor;
    self.typeImage.layer.borderWidth = 1.0;
    
    CGFloat typeImageX = 5;
    CGFloat typeImageY = 2;
    
    self.typeImage.frame = CGRectMake(typeImageX, typeImageY, 32, 32);
    [self addSubview:self.typeImage];
    
    //        CGFloat delta = self.frame.size.height - (self.data.insets.top + self.data.insets.bottom + self.data.view.frame.size.height);
    //        if (delta > 0) y = delta;
    
    //The followings are the bubble image attributes
    //    CGFloat width = self.data.view.frame.size.width;
    CGFloat width = 255.0f;
    CGFloat height = self.data.view.frame.size.height;
    
    CGFloat x = 18;
    CGFloat y = 20;
    
    [self.customView removeFromSuperview];
    self.customView = self.data.view;
    self.customView.frame = CGRectMake(x + self.data.insets.left, y + self.data.insets.top, width, height);
    [self.contentView addSubview:self.customView];
    
    self.bubbleImage.image = [[UIImage imageNamed:@"bubble.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 24, 20, 24) resizingMode:UIImageResizingModeStretch];
    
    self.bubbleImage.frame = CGRectMake(x, y, width + self.data.insets.left + self.data.insets.right, height + self.data.insets.top + self.data.insets.bottom);
}

@end
