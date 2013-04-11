//
//  SidebarViewController.m
//  MultimediaProject
//
//  Created by PowerQian on 12/26/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "SidebarViewController.h"
#import "TextMessageViewController.h"
#import "ECSlidingViewController.h"
#import "MainViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface SidebarViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation SidebarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willExitMainScreen)]) {
        [self.delegate willExitMainScreen];
    }
    if ([segue.identifier isEqualToString:@"Text Message"]) {
        [self.slidingViewController resetTopView];
    }
}

#pragma * Sidebar Action

- (IBAction)takePic:(UIButton *)sender {
    [self.slidingViewController resetTopView];
    if ([self.delegate respondsToSelector:@selector(willExitMainScreen)]) {
        [self.delegate willExitMainScreen];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}
- (IBAction)choosePhoto:(UIButton *)sender {
    [self.slidingViewController resetTopView];
    if ([self.delegate respondsToSelector:@selector(willExitMainScreen)]) {
        [self.delegate willExitMainScreen];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

- (void)didFinishTextInput:(NSString *)inputText
{
    [self.delegate didAddNewText:inputText];
}

#pragma * ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    DataType imageType;
    NSData* pictureData;
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeJPEG]
            || [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeJPEG2000]
            || [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
            imageType = kDataTypeImageJPEG;
            pictureData = UIImageJPEGRepresentation(image, 1);
        } else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypePNG]) {
            imageType = kDataTypeImagePNG;
            pictureData = UIImagePNGRepresentation(image);
        }
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [self.delegate didAddNewPhoto:image corespondingData:pictureData];
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
