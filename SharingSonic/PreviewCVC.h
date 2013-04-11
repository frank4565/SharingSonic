//
//  PreviewCVC.h
//  MultimediaProject
//
//  Created by PowerQian on 2/23/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataType.h"

@interface PreviewCVC : UICollectionViewCell

@property (nonatomic) DataType type;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *hash;
@property (weak, nonatomic) IBOutlet UIImageView *underlineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) BOOL isSelected;

//-(UIImage *)imageFromText:(NSString *)text font:(UIFont *)font;
-(UIImage *)textImage;

@end
