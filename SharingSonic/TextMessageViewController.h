//
//  TextMessageViewController.h
//  MultimediaProject
//
//  Created by PowerQian on 12/26/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextMessageViewControllerDelegate <NSObject>

- (void)doneWithTextInput:(NSString *)inputText;

@end

@interface TextMessageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet id <TextMessageViewControllerDelegate> delegate;
@end
