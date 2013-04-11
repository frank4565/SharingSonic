//
//  SonicTableViewCell.h
//  MultimediaProject
//
//  Created by PowerQian on 12/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSSonicData.h"

@protocol SonicTableViewCellDelegate <NSObject>

- (void)tappedOnPhotoWithImage:(UIImage *)image;

@end

@interface SonicTableViewCell : UITableViewCell

@property (nonatomic, strong) NSSonicData *data;

@property (nonatomic, weak) id <SonicTableViewCellDelegate> delegate;

@end
