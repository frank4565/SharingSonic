//
//  SSImageViewController.m
//  MultimediaProject
//
//  Created by PowerQian on 4/10/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSImageViewController.h"

@interface SSImageViewController () <UIActionSheetDelegate>

@end

@implementation SSImageViewController

- (void)_dismiss:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#define ACTION_SHEET_TITLE @"What to Do"
#define CANCEL @"Cancel"
#define SAVE_TO_PHOTO_ALBUM @"Save to Photo Album"
#define COPY_TO_CLIPBOARD @"Copy to Clipboard"

- (void)_action:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:ACTION_SHEET_TITLE delegate:self cancelButtonTitle:CANCEL destructiveButtonTitle:nil otherButtonTitles:SAVE_TO_PHOTO_ALBUM, COPY_TO_CLIPBOARD, nil];
        actionSheet.delegate = self;
        [actionSheet showInView:self.view];
    }
}

#pragma mark - ActionSheetDelegate
//Deal with the action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
//    if ([choice isEqualToString:SAVE_TO_PHOTO_ALBUM]) {
//        UIImageWriteToSavedPhotosAlbum(self.imageToShow, nil, nil, nil);
//    }
//    else if ([choice isEqualToString:COPY_TO_CLIPBOARD]) {
//        //        [[UIPasteboard generalPasteboard] setImage:self.imageToShow];
//        UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
//        [gpBoard setData:UIImageJPEGRepresentation(self.imageToShow,1.0) forPasteboardType:(id)kUTTypeJPEG];
//    }
}

#pragma mark - View Controller Life Cycle.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_action:)];
    [self.view addGestureRecognizer:longPressGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismiss:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
