//
//  SidebarViewController.h
//  MultimediaProject
//
//  Created by PowerQian on 12/26/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SidebarViewControllerDelegate <NSObject>

- (void)didAddNewText:(NSString *)text;
- (void)didAddNewPhoto:(UIImage *)image corespondingData:(NSData *)data;

@optional
- (void)willExitMainScreen;

@end

@interface SidebarViewController : UIViewController

@property (nonatomic,weak) id <SidebarViewControllerDelegate> delegate;

@end
