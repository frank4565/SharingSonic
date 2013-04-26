//
//  MainViewController.m
//  MultimediaProject
//
//  Created by PowerQian on 1/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "MainViewController.h"
#import "MD5.h"
#import "ImageViewController.h"
#import "TextMessageViewController.h"
#import "SVProgressHUD.h"
#import "PreviewCVC.h"
#import "SSBonjour.h"
#import "ReflectionView.h"
#import "FXImageView.h"
#import "UIButtonWithLargerTapArea.h"
#import "NSString+DTUTI.h"
#import "SSFile.h"

#import <QuartzCore/QuartzCore.h>

@interface MainViewController ()
<UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
TextMessageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) UIImageView *addButtonImageView;
@property (nonatomic) BOOL isAdding;

//Other property of this controller
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSURL *imageURLToBeShownInFullScreen;
@property (nonatomic, readonly) BOOL bonjourIsOn;
@property (nonatomic, readonly) BOOL internetIsOn;
//Sound Property
@property (nonatomic) Float32 *sampleData;
@property (nonatomic) BOOL hasSample;
//Bonjour
@property (nonatomic, strong) SSBonjour *bonjour;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
//File
@property (nonatomic, strong) SSFile *files;
@end

@implementation MainViewController
//Must add this synthesize
@synthesize ssObjects = _ssObjects;

NSString * const KEY_FOR_TYPE = @"Type";
NSString * const KEY_FOR_DATA = @"Data";
NSString * const KEY_FOR_HASH = @"Hash";
NSString * const KEY_FOR_THUM = @"Thumb";


#pragma mark Lazy initializer & setter and getter

- (void)setHashString:(NSString *)hashString
{
    if ([hashString isKindOfClass:[NSNull class]]) {
        _hashString = nil;
    } else if (_hashString != hashString) {
        _hashString = hashString;
        NSLog(@"Current Hash String: %@", self.hashString);
    }
}

- (SSFile *)files
{
    if (!_files) {
        _files = [[SSFile alloc] init];
    }
    return _files;
}

- (NSMutableArray *)ssObjects
{
    if (!_ssObjects) {
        NSArray *fileArray = self.files.fileArray;
        _ssObjects = [[NSMutableArray alloc] initWithCapacity:fileArray.count];
        for (NSDictionary *file in fileArray) {
            NSDictionary *newObj = @{KEY_FOR_TYPE: @([SSFile fileDataTypeOf:file]), KEY_FOR_DATA: [SSFile fileDataOf:file], KEY_FOR_HASH: [SSFile fileHashStringOf:file], KEY_FOR_THUM: [SSFile hasThumbImage:file] ? @"YES" : @"NO"};
            [_ssObjects addObject:newObj];
        }
        [self.carousel reloadData];
    }
    return _ssObjects;
}

- (void)setSsObjects:(NSMutableArray *)ssObjects
{
    _ssObjects = ssObjects;
    [self.carousel reloadData];
}

static NSString const *BONJOUR_SWITCH_VALUE = @"Bonjour switch value";
static NSString const *INTERNET_SWITCH_VALUE = @"Internet switch value";

- (BOOL)bonjourIsOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)BONJOUR_SWITCH_VALUE];
}

- (BOOL)internetIsOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)INTERNET_SWITCH_VALUE];
}

//#pragma mark - Private Methods of CollectionView Related

//- (void)_addObjectToSonicData:(NSSonicData *)object
//{
//    if (!self.sonicData) {
//        self.sonicData = [[NSMutableArray alloc] initWithObjects:object, nil];
//    } else {
//        NSSonicData *last = (NSSonicData *)[self.sonicData lastObject];
//        if (last.type == SonicTypeIndicator) {
//            [self.sonicData replaceObjectAtIndex:([self.sonicData count] - 1) withObject:object];
//        } else [self.sonicData addObject:object];
//    }
//    [self.sonicTable reloadData];
//    
//    
//    if (self.sonicTable.contentSize.height > self.sonicTable.frame.size.height)
//    {
//        CGPoint offset = CGPointMake(0, self.sonicTable.contentSize.height - self.sonicTable.frame.size.height);
//        [self.sonicTable setContentOffset:offset animated:YES];
//    }
//}

//- (void)_programmaticallySelectCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    self.selectedIndexPath = indexPath;
//    UICollectionViewCell *cellToSelect = [self.collectionView cellForItemAtIndexPath:indexPath];
//    if ([cellToSelect isKindOfClass:[PreviewCVC class]]) {
//        PreviewCVC *pcvc = (PreviewCVC *)cellToSelect;
//        pcvc.isSelected = YES;
//    }
//}
//
//- (void)_programmaticallyDeselectCellAtIndexPath:(NSIndexPath *)indexPath
//{
//    self.selectedIndexPath = nil;
//    UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:indexPath];
//    if ([selectedCell isKindOfClass:[PreviewCVC class]]) {
//        PreviewCVC *cell = (PreviewCVC *)selectedCell;
//        cell.isSelected = NO;
//    }
//}
//
//- (void)_addObjectToCollectionView:(id)object hashString:(NSString *)hash
//{
//    if (self.selectedIndexPath) {
//        [self _programmaticallyDeselectCellAtIndexPath:self.selectedIndexPath];
//    }
//    if ([self.ssObjects count] == self.cellNumber) {
//        NSIndexPath *indexPathHead = [NSIndexPath indexPathForItem:0 inSection:0];
//        [self.collectionView performBatchUpdates:^{
//            [self.ssObjects removeObjectAtIndex:0];
//            [self.collectionView deleteItemsAtIndexPaths:@[indexPathHead]];
//        } completion:NULL];
//    }
//    
//    NSIndexPath *indexPathEnd = [NSIndexPath indexPathForItem:(self.cellNumber - 1) inSection:0];
//
//    if ([object isKindOfClass:[UIImage class]]) {
//        UIImage *image = (UIImage *)object;
//        [self.collectionView performBatchUpdates:^{
//            [self.ssObjects addObject:@{KEY_FOR_TYPE: @(kDataTypeImageJPEG), KEY_FOR_DATA:image, KEY_FOR_HASH:hash}];
//            [self.collectionView insertItemsAtIndexPaths:@[indexPathEnd]];
//        }
//                                      completion:^(BOOL finished){
//                                          if (finished) {
//                                              [self _programmaticallySelectCellAtIndexPath:indexPathEnd];
//                                          }
//                                      }];
//    } else if ([object isKindOfClass:[NSString class]]) {
//        NSString *text = (NSString *)object;
//        [self.collectionView performBatchUpdates:^{
//            [self.ssObjects addObject:@{KEY_FOR_TYPE: @(kDataTypeText), KEY_FOR_DATA:text, KEY_FOR_HASH:hash}];
//            [self.collectionView insertItemsAtIndexPaths:@[indexPathEnd]];
//        }
//                                      completion:^(BOOL finished){
//                                          if (finished) {
//                                              [self _programmaticallySelectCellAtIndexPath:indexPathEnd];
//                                          }
//                                      }];
//    }
//}
//
//#define ANIMATION_DURATION 0.25
//
//- (void) _resetContentViewWithObject:(id)object
//{
//    self.contentImageView.image = nil;
//    self.contentImageView.hidden = YES;
//    self.contentTextView.text = nil;
//    self.contentTextView.hidden = YES;
//    
//    if ([object isKindOfClass:[UIImage class]]) {
//        UIImage *image = (UIImage *)object;
//        [UIView transitionWithView:self.contentImageView
//                          duration:ANIMATION_DURATION
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            self.contentImageView.image = image;
//                            self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
//                            self.contentImageView.hidden = NO;
//                        }
//                        completion:nil];
//    } else if ([object isKindOfClass:[NSString class]]) {
//        NSString *string = (NSString *)object;
//        [UIView transitionWithView:self.contentTextView
//                          duration:ANIMATION_DURATION
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            self.contentTextView.text = string;
//                            self.contentTextView.textAlignment = NSTextAlignmentNatural;
//                            self.contentTextView.hidden = NO;
//                        }
//                        completion:nil];
//    } else {
//        NSLog(@"Object Type Not Supported Yet");
//    }
//}

#pragma mark -
#pragma mark Private Helper Method

- (void)_uploadData:(NSData *)data type:(DataType)type
{
    
}

#pragma mark Carousel Related Private Method
#define FIRST_OBJECT 0

- (void)_replaceObjectAfterAdding:(id)object correspondingHash:(NSString *)hash
{
    NSDictionary *newObj;
    DataType type;
    if ([object isKindOfClass:[UIImage class]]) {
        type = kDataTypeImageJPEG;
        newObj = @{KEY_FOR_TYPE: @(type), KEY_FOR_DATA: UIImageJPEGRepresentation(object, 1), KEY_FOR_HASH: hash, KEY_FOR_THUM: @"NO"};
    } else if ([object isKindOfClass:[NSString class]]) {
        type = kDataTypeText;
        newObj = @{KEY_FOR_TYPE: @(type), KEY_FOR_DATA: object, KEY_FOR_HASH: hash};
    } else {
        NSLog(@"Error in - (void)_replaceObjectAfterAdding:(id)object correspondingHash:(NSString *)hash");
    }
    
    
    [self.ssObjects replaceObjectAtIndex:[self.ssObjects count] - 1 withObject:newObj];
    [self.carousel reloadItemAtIndex:[self.ssObjects count] - 1 animated:YES];
    
    self.isAdding = NO;
    [self _transformBack];
}

- (void)_addObject:(id)object toCarousel:(iCarousel *)carousel withHash:(NSString *)hash
{
    //The following commented codes are for the situtation when there is MAX_Object_Number
//    if (carousel.numberOfItems > 0 && ![object isKindOfClass:[NSNull class]])
//    {
//        [self.ssObjects removeObjectAtIndex:FIRST_OBJECT];
//        [carousel removeItemAtIndex:FIRST_OBJECT animated:YES];
//    }
    
    if ([object isKindOfClass:[UIImage class]]) {
        UIImage *image = (UIImage *)object;
        [self.ssObjects addObject:@{KEY_FOR_TYPE: @(kDataTypeImageJPEG), KEY_FOR_DATA:image, KEY_FOR_HASH:hash}];
    } else if ([object isKindOfClass:[NSString class]]) {
        NSString *text = (NSString *)object;
        [self.ssObjects addObject:@{KEY_FOR_TYPE: @(kDataTypeText), KEY_FOR_DATA:text, KEY_FOR_HASH:hash}];
    } else if ([object isKindOfClass:[NSNull class]]) {
        [self.ssObjects addObject:@{KEY_FOR_TYPE :@(kDataTypeNoType), KEY_FOR_DATA : [NSNull null], KEY_FOR_HASH : [NSNull null]}];
    }
    
    [carousel insertItemAtIndex:[self.ssObjects count] animated:YES];
    [carousel scrollToItemAtIndex:[self.ssObjects count] animated:YES];
}



#pragma mark - Target Action
- (IBAction)share:(UIBarButtonItem *)sender {
    if (self.hashString) {
        OSStatus err = [[SoundGenerator defaultGenerator] generateSoundOfHashString:self.hashString];
        if (err != noErr) {
            NSLog(@"Error occured : %ld", err);
        } else {
            [sender setEnabled:NO];
        }
    } else {
        UIAlertView *addThings = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Nothing to send. Please add something" delegate:self cancelButtonTitle:@"I Know" otherButtonTitles:nil, nil];
        [addThings show];
    }
}

#define TRANSFORM_ANIMATION_DURATION 0.4f
- (void)_transform
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TRANSFORM_ANIMATION_DURATION];
    self.addButtonImageView.transform = CGAffineTransformMakeRotation(M_PI_4);
    [UIView commitAnimations];
}

- (void)_transformBack
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TRANSFORM_ANIMATION_DURATION];
    self.addButtonImageView.transform = CGAffineTransformMakeRotation(0);
    [UIView commitAnimations];
}

- (IBAction)add:(UIBarButtonItem *)sender {
    if (self.isAdding) {
        [self _transformBack];
        [self.carousel removeItemAtIndex:self.carousel.numberOfItems - 1 animated:YES];
        [self.ssObjects removeLastObject];
        self.isAdding = NO;
    } else {
        [self _transform];
        [self _addObject:[NSNull null] toCarousel:self.carousel withHash:nil];
        self.isAdding = YES;
    }
}

#define INPUT_TEXT_IDENTIFIER @"Input Text"
- (IBAction)addText:(UIButton *)sender
{
    NSLog(@"add text");
    [self performSegueWithIdentifier:INPUT_TEXT_IDENTIFIER sender:self];
}

- (void)_imagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([mediaTypes containsObject:(NSString *)kUTTypeImage]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = sourceType;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = NO;
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else {
        NSString *message;
        if (sourceType == UIImagePickerControllerSourceTypeCamera) {
            message = @"taking picture";
        } else if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
            message = @"choosing photo";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[@"Your device doesn't support " stringByAppendingString:message] delegate:self cancelButtonTitle:@"I know" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)takePhoto:(UIButton *)sender
{
    NSLog(@"take photo");
    
    [self _imagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    
}

- (IBAction)choosePhoto:(UIButton *)sender
{
    NSLog(@"choose photo");
    
    [self _imagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)openInApps:(UIBarButtonItem *)sender
{     
    [self.docInteractionController presentOptionsMenuFromBarButtonItem:sender animated:YES];
    // [self.docInteractionController presentOpenInMenuFromBarButtonItem:sender animated:YES];
    
    /**For priview
    Only supoort iOS recognizable file
    */
    // [self.docInteractionController presentPreviewAnimated:YES];
}

- (IBAction)moreAction:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"To Do" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Open In...", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // item to use.
    NSUInteger indexOfCenteredItem = self.carousel.currentItemIndex;
    
    if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        NSLog(@"Open In...");
        //TODO: Open in
    } else if (buttonIndex == actionSheet.destructiveButtonIndex) {
        //TODO: Delete current item.
    }
}

#pragma mark - Updating UI
- (void)_startNetworkingAndUpdateUI
{
//    [self.sendButton setHidden:YES];
//    [self.spinner setHidden:NO];
//    [self.spinner startAnimating];
    [self.progressView setProgress:0];
    [self.progressView setHidden:NO];
//    self.contentImageView.alpha = 0.5;
//    self.contentTextView.alpha = 0.5;
}

- (void)_stopNetworkingAndUpdateUI
{
//    [self.spinner stopAnimating];
    [self.progressView setHidden:YES];
    [self.sendButton setEnabled:YES];
//    [self.sendButton setHidden:NO];
//    self.sendButton.alpha = 1;
//    self.contentTextView.alpha = 1;
//    self.contentImageView.alpha = 1;
}


#pragma mark - NetworkHelperDelegate

- (void)uploadDidFinish
{
    [self _stopNetworkingAndUpdateUI];
    NSLog(@"Success!");
}

- (void)didSendDataLengthInTotal:(long long)totalSentLength withTotalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    float percentage = (float)totalSentLength / (float)totalBytesExpectedToWrite;
    [self.progressView setProgress:percentage animated:YES];
}

- (void)didReceiveDataLengthInTotal:(long long)totalReceivedLength withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead
{    
    float percentage = (float)totalReceivedLength / (float)totalBytesExpectedToRead;
    [self.progressView setProgress:percentage animated:YES];
}

- (void)downloadDidFinishWithData:(NSData *)data contentType:(DataType)type
{
    [self _stopNetworkingAndUpdateUI];
    NSString *hashStringOfData = [[MD5 defaultMD5] md5ForData:data];
        
    if (type == kDataTypeImageJPEG || type == kDataTypeImagePNG) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if ([[self.ssObjects lastObject][KEY_FOR_TYPE] intValue] == kDataTypeNoType) {
            [self _replaceObjectAfterAdding:image correspondingHash:hashStringOfData];
        } else {
            [self _addObject:image toCarousel:self.carousel withHash:hashStringOfData];
        }
    } else if (type == kDataTypeText) {
        NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([[self.ssObjects lastObject][KEY_FOR_TYPE] intValue] == kDataTypeNoType) {
            [self _replaceObjectAfterAdding:receivedText correspondingHash:hashStringOfData];
        } else {
            [self _addObject:receivedText toCarousel:self.carousel withHash:hashStringOfData];
        }
//        [SSFile saveFileToDocumentsOfName:@"Text.txt" withData:data];
    } else {
        NSLog(@"Error occurs!");
    }
}

- (void)downloadDidFinishWithFile:(NSString *)filePath
{
    [self _stopNetworkingAndUpdateUI];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *hashStringOfData = [[MD5 defaultMD5] md5ForData:data];
    
    if ([(NSString *)filePath.pathComponents.lastObject isImageFileName]) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if ([[self.ssObjects lastObject][KEY_FOR_TYPE] intValue] == kDataTypeNoType) {
            [self _replaceObjectAfterAdding:image correspondingHash:hashStringOfData];
        } else {
            [self _addObject:image toCarousel:self.carousel withHash:hashStringOfData];
        }
    } /*else if (type == kDataTypeText) {
//        NSString *receivedText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        if ([[self.ssObjects lastObject][KEY_FOR_TYPE] intValue] == kDataTypeNoType) {
//            [self _replaceObjectAfterAdding:receivedText correspondingHash:hashStringOfData];
//        } else {
//            [self _addObject:receivedText toCarousel:self.carousel withHash:hashStringOfData];
//        }
        //        [SSFile saveFileToDocumentsOfName:@"Text.txt" withData:data];
    } else {
        NSLog(@"Error occurs!");
    }*/
    [self setupDocumentControllerWithURL:[NSURL fileURLWithPath:filePath]];
}

- (void)downloadDidFinishWithData:(NSData *)data ofFile:(NSString *)filePath
{
    [self _stopNetworkingAndUpdateUI];
    
    NSString *hash = [[MD5 defaultMD5] md5ForData:data];
    
    if ([(NSString *)filePath.pathComponents.lastObject isImageFileName]) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        if ([[self.ssObjects lastObject][KEY_FOR_TYPE] intValue] == kDataTypeNoType) {
            [self _replaceObjectAfterAdding:image correspondingHash:hash];
        } else {
            [self _addObject:image toCarousel:self.carousel withHash:hash];
        }
    } else if ([(NSString *)filePath.pathComponents.lastObject isTextFileName]) {
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([[self.ssObjects lastObject][KEY_FOR_TYPE] intValue] == kDataTypeNoType) {
            [self _replaceObjectAfterAdding:text correspondingHash:hash];
        } else {
            [self _addObject:text toCarousel:self.carousel withHash:hash];
        }
    } else {
        NSLog(@"Other types!");
    }

    [self setupDocumentControllerWithURL:[NSURL fileURLWithPath:filePath]];
}

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (void)failedWithError:(NSError *)error
{
    [self _stopNetworkingAndUpdateUI];
    
    if ([error code] == -1004) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error occurs" message:@"Preparetion failed. Check your Network Status." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
    } else if ([error code] == -1002) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error occurs" message:@"Server is not ready!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
        NSLog(@"%@",error);
    }
    
}

//#pragma mark - SidebarViewControllerDelegate
//
//- (void)didAddNewText:(NSString *)text
//{
////    NSSonicData *newText = [NSSonicData dataWithText:text date:[NSDate dateWithTimeIntervalSinceNow:0] type:SonicTypeText];
////    [self _addObjectToSonicData:newText];
////    [self _resetContentViewWithObject:text];
//    
//    NSData *dataToSend = [text dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *hashString = [[MD5 defaultMD5] md5ForData:dataToSend];
//    
////    [self _addObjectToCollectionView:text hashString:hashString];
//    [self _addObject:text toCarousel:self.carousel withHash:hashString];
//    self.hashString = hashString;
//    
//    [self _startNetworkingAndUpdateUI];
//    [[NetworkHelper helper] uploadData:dataToSend contentType:kDataTypeText WithHashString:self.hashString delegate:self];
//}
//
//- (void)didAddNewPhoto:(UIImage *)image corespondingData:(NSData *)data
//{
////    NSSonicData *newPhoto = [NSSonicData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:SonicTypePhoto];
////    [self _addObjectToSonicData:newPhoto];
////    [self _addObjectToCollectionView:image hashString:[[MD5 defaultMD5] md5ForData:data]];
////    [self _resetContentViewWithObject:image];
//    
//    [self _addObject:image toCarousel:self.carousel withHash:[[MD5 defaultMD5] md5ForData:data]];
//    
//    self.hashString = [[MD5 defaultMD5] md5ForData:data];
//    
//    [self _startNetworkingAndUpdateUI];
//    
//    if (self.bonjour.foundServices.count > 0) {
////        [self.bonjour sendData:data];
//    } else {
//        [[NetworkHelper helper] uploadData:data contentType:kDataTypeImageJPEG WithHashString:self.hashString delegate:self];
//    }
//}
//
//- (void)willExitMainScreen
//{
////    if ([SoundGenerator defaultGenerator].isSending) {
////        [[SoundGenerator defaultGenerator] stopSound];
////    }
////    [[SoundReceiver defaultReceiver] pauseRecording];
//
//    //    self.waveform.dataSource = nil;
//    //    [SoundReceiver defaultReceiver].delegate = nil;
//}

#pragma mark - SoundGeneratorDelegate
- (void)soundGeneratingWillStart
{
    [SoundReceiver defaultReceiver].shouldAnalyze = NO;
}

- (void)soundGeneratingDidStart
{
    self.waveform.backgroundColor = [UIColor cyanColor];
}

- (void)soundGeneratingDidStop
{
    self.waveform.backgroundColor = [UIColor clearColor];
    [SoundReceiver defaultReceiver].shouldAnalyze = YES;
    
    [self.sendButton setEnabled:YES];
//    self.sendButton.alpha = 1;
}

#pragma mark - SoundReceiverDelegate

- (void)didGetResult:(NSString *)resultHashString
{
    NSLog(@"Get the analyzed result: %@",resultHashString);
    BOOL same = NO;
    for (NSDictionary *ssObject in self.ssObjects) {
        if ([ssObject[KEY_FOR_TYPE] intValue] != kDataTypeNoType && [ssObject[KEY_FOR_HASH] isEqualToString:resultHashString]) {
            same = YES;
            NSUInteger index = [self.ssObjects indexOfObject:ssObject];
            [self.carousel scrollToItemAtIndex:index animated:YES];
            break;
        }
    }
    if (!same) {
        self.hashString = resultHashString;
        [self _startNetworkingAndUpdateUI];
        
//        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        [indicator startAnimating];
//        NSSonicData *newAcitivityIndicator = [[NSSonicData alloc] initWithView:indicator date:[NSDate dateWithTimeIntervalSinceNow:0] type:SonicTypeIndicator insets:UIEdgeInsetsMake(18, 15, 18, 15)];
//        [self _addObjectToSonicData:newAcitivityIndicator];
        
        [[NetworkHelper helper] getDataOfHashString:self.hashString delegate:self];
    }
    
}
- (void)didDetectStartingPattern
{
    self.waveform.backgroundColor = [UIColor cyanColor];
}
- (void)didDetectEndingPattern
{
    self.waveform.backgroundColor = [UIColor clearColor];
}
- (void)timeoutAndFailedToGetResult
{
    //TODO:
}
- (void)didGetSamples:(Float32 *)samples
{
    self.sampleData = samples;
    self.hasSample = YES;
    
    if (self.waveform.window && !self.waveform.isUpdatingUI) {
        [self.waveform setNeedsDisplay];
    }
}

#pragma mark - WaveViewDataSource
- (Float32)_translateIntodBValue:(Float32)value
{
    Float32 returnValue = 0;
    if (value > 0) {
        returnValue = 10 * log10f(value);
    } else if (value < 0) {
        returnValue = -10 * log10f(-value);
    } else if (value == 0) {
//        TODO
//        NSLog(@"Sample Value = 0");
        returnValue = 96;
    }
    return returnValue;
}

- (Float32)yValueForX:(Float32)xValue inPixelValue:(CGFloat)pixel forSender:(WaveView *)sender
{
    Float32 yValue = 0;
    Float32 yValueIndB = 0;
    
    if (self.hasSample) {
        Float32 coefficent = pixel / SINGLE_BUFFER_SAMPLE_COUNT;
        Float32 realXValue = xValue / coefficent;
        NSUInteger sampleNumber = floorf(realXValue);
        Float32 xFloatValue = realXValue - sampleNumber;
        
        yValue = self.sampleData[sampleNumber];
        Float32 nextYValue;
        if (sampleNumber == (SINGLE_BUFFER_SAMPLE_COUNT - 1)) {
            nextYValue = yValue;
        } else {
            nextYValue = self.sampleData[sampleNumber + 1];
        }
        
        yValue = yValue + (yValue - nextYValue) * xFloatValue;
        yValueIndB = [self _translateIntodBValue:yValue];
    }
    return yValueIndB;
}

//#pragma mark SonicTableViewDataSource
//
//- (NSInteger)rowsForSonicTable:(SonicTableView *)tableView
//{
//    return [self.sonicData count];
//}
//
//- (NSSonicData *)sonicTableView:(SonicTableView *)tableView dataForRow:(NSInteger)row
//{
//    return [self.sonicData objectAtIndex:row];
//}


//#pragma mark - UICollectionViewDataSource
//
//- (int)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return [self.ssObjects count];
//}
//
//#define CORNER_RADIUS_OF_CELL 12.0f
//#define TEXT_SIZE_OF_CELL 8
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Preview" forIndexPath:indexPath];
//    if ([cell isKindOfClass:[PreviewCVC class]]) {
//        PreviewCVC *previewCvc = (PreviewCVC *)cell;
//        previewCvc.imageView.layer.cornerRadius = CORNER_RADIUS_OF_CELL;
//        previewCvc.imageView.layer.masksToBounds = YES;
//        
//        previewCvc.type = [self.ssObjects[indexPath.item][KEY_FOR_TYPE] intValue];
//        previewCvc.hash = self.ssObjects[indexPath.item][KEY_FOR_HASH];
//        if (previewCvc.type == kDataTypeImageJPEG) {
//            previewCvc.image = self.ssObjects[indexPath.item][KEY_FOR_DATA];
//        } else if (previewCvc.type == kDataTypeText) {
//            previewCvc.text = self.ssObjects[indexPath.item][KEY_FOR_DATA];
//            previewCvc.image = [previewCvc textImage];
//        }
//    }
//    return cell;
//}
//
//#pragma mark - UICollectionViewDelegate
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    //deselect last cell programmatically because its underline is set programmatically
//    [self _programmaticallyDeselectCellAtIndexPath:self.selectedIndexPath];
//    self.selectedIndexPath = indexPath;
//    
//    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
//    if ([selectedCell isKindOfClass:[PreviewCVC class]]) {
//        PreviewCVC *cell = (PreviewCVC *)selectedCell;
//        if (cell.type == kDataTypeImageJPEG) {
//            UIImage *imageOfCell = cell.image;
//            [self _resetContentViewWithObject:imageOfCell];
//            self.hashString = cell.hash;
//        } else if (cell.type == kDataTypeText) {
//            NSString *text = cell.text;
//            [self _resetContentViewWithObject:text];
//            self.hashString = cell.hash;
//        }
//        cell.isSelected = YES;
//    }
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *deselectedCell = [collectionView cellForItemAtIndexPath:indexPath];
//    if ([deselectedCell isKindOfClass:[PreviewCVC class]]) {
//        PreviewCVC *cell = (PreviewCVC *)deselectedCell;
//        cell.isSelected = NO;
//    }
//}

#pragma mark - CarouselDataSource
#define CAROUSEL_CONTENT_SIZE_RECT CGRectMake(0, 0, 200.0f, 200.0f)
#define IMAGE_VIEW_TAG 1
#define TEXT_VIEW_TAG 99
#define ADD_VIEW_TAG 1024

- (CGRect)carouselContentSizeRect
{
    return CGRectMake(0, 0, 200.0f, 200.0f);
}

- (void)_removeSubviewsOfView:(UIView *)view exceptView:(UIView *)exceptView
{
    for (id sub in view.subviews) {
        if (sub != exceptView && [sub isKindOfClass:[UIView class]])
            [(UIView *)sub removeFromSuperview];
    }
}

- (UITextView *)_allocTextViewForReflectionView:(ReflectionView *)view
{
    UITextView *textView = [[UITextView alloc] initWithFrame:view.bounds];
    textView.font = [UIFont systemFontOfSize:22];
    textView.textAlignment = NSTextAlignmentNatural;
    textView.editable = NO;
    textView.tag = TEXT_VIEW_TAG;
    [view addSubview:textView];
    return textView;
}

- (FXImageView *)_allocFXImageView
{
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
//    imageView.contentMode = UIViewContentModeScaleToFill;
//    imageView.tag = IMAGE_VIEW_TAG;
//    [view addSubview:imageView];
//    return imageView;
    FXImageView *imageView = [[FXImageView alloc] initWithFrame:[self carouselContentSizeRect]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.asynchronous = YES;
    imageView.reflectionScale = 0.5f;
    imageView.reflectionAlpha = 0.5f;
    imageView.reflectionGap = 4.0f;
    imageView.shadowOffset = CGSizeMake(0.0f, 2.0f);
    imageView.shadowBlur = 5.0f;

//    imageView.tag = IMAGE_VIEW_TAG;
    return imageView;
}

- (ReflectionView *)_allocReflectionView
{
    ReflectionView *reflectionView = [[ReflectionView alloc] initWithFrame:[self carouselContentSizeRect]];
    reflectionView.dynamic = YES;
    reflectionView.reflectionGap = 4.0f;
    reflectionView.reflectionScale = 0.5f;
    reflectionView.reflectionAlpha = 0.5f;
    return reflectionView;
}


- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.ssObjects count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    FXImageView *imageView = nil;
    UITextView *textView = nil;
    UIView *addView = nil;
    
    //Determine content type
    DataType type;    
    type = [self.ssObjects[index][KEY_FOR_TYPE] intValue];
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        if (type == kDataTypeImageJPEG) {
            // Type is image, use FXImageView
            imageView = [self _allocFXImageView];
            view = imageView;
        } else {
            // Type is not image, use ReflectionView and add subview.
            ReflectionView *reflectionView = [self _allocReflectionView];
            
            if (type == kDataTypeText) {
                textView = [self _allocTextViewForReflectionView:reflectionView];
                view = reflectionView;
            } else if (type == kDataTypeNoType) {
                //addView
                addView = [[[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil] lastObject];
                addView.tag = ADD_VIEW_TAG;
                [reflectionView addSubview:addView];
                view = reflectionView;
            } else if (type == kDataTypeUnsupported) {
                //TODO: Other type to support
            }            
        }
    }
    else
    {
        if (type == kDataTypeImageJPEG) {
            // Due to the different class for image and others,
            // only need to check the class type. If it is not
            // a FXImageView, alloc a new one. Else don't do anything
            // and the image will change below.
            
            if (![view isKindOfClass:[FXImageView class]]) {
                view = [self _allocFXImageView];
            }
            
//            if ([view viewWithTag:IMAGE_VIEW_TAG]) {
//                imageView = (FXImageView *)[view viewWithTag:IMAGE_VIEW_TAG];
//            }
//            else imageView = [self _allocImageViewForReflectionView:view];
//            [self _removeSubviewsOfView:view exceptView:imageView];
        } else {
            // Check if "view" is ReflectionView
            if ([view isKindOfClass:[ReflectionView class]]) {
                // Retrive tagged view according to different type.
                if (type == kDataTypeText) {
//                    if ([view viewWithTag:TEXT_VIEW_TAG]) {
                    textView = (UITextView *)[view viewWithTag:TEXT_VIEW_TAG];
//                    }
//            [self _removeSubviewsOfView:view exceptView:textView];
                } else if (type == kDataTypeUnsupported) {
                    //TODO: Other type to support
                } else if (type == kDataTypeNoType) {
//                    if ([view viewWithTag:ADD_VIEW_TAG]) {
                        addView = [view viewWithTag:ADD_VIEW_TAG];
//                    }
                    //            else {
                    //                addView =
                    //                addView.tag = ADD_VIEW_TAG;
                    //                [view addSubview:addView];
                    //            }
                    //            [self _removeSubviewsOfView:view exceptView:addView];
                }

            } else {
                // view is not a ReflectionView, i.e. it's FXImageView,
                // then treat the situation like view == nil, since the
                // view is not useful.
                
                ReflectionView *reflectionView = [self _allocReflectionView];
                
                if (type == kDataTypeText) {
                    textView = [self _allocTextViewForReflectionView:reflectionView];
                    view = reflectionView;
                } else if (type == kDataTypeNoType) {
                    //addView
                    addView = [[[NSBundle mainBundle] loadNibNamed:@"CustomView" owner:self options:nil] lastObject];
                    addView.tag = ADD_VIEW_TAG;
                    [reflectionView addSubview:addView];
                    view = reflectionView;
                } else if (type == kDataTypeUnsupported) {
                    //TODO: Other type to support
                }
            }
        }
            
    }
    
    id content = self.ssObjects[index][KEY_FOR_DATA];
    
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    
    if (type == kDataTypeImageJPEG || type == kDataTypeImagePNG) {
//        imageView.image = nil;
//        imageView.image = noImage;
//        dispatch_queue_t imageQueue = dispatch_queue_create("Image Queue", NULL);
//        dispatch_async(imageQueue, ^(){
//            UIImage *image = [UIImage imageWithData:content];
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                imageView.image = image;
//            });
//        });
        ((FXImageView *)view).processedImage = [UIImage imageNamed:@"placeholder.png"];
        if ([content isKindOfClass:[NSData class]]) {
            ((FXImageView *)view).image = [UIImage imageWithData:content];
        } else if ([content isKindOfClass:[UIImage class]]) {
            ((FXImageView *)view).image = content;
        } else {
            return nil;
        }
        // cache thumb image.
        ((FXImageView *)view).customEffectsBlock = ^(UIImage *image){
            if ([self.ssObjects[index][KEY_FOR_THUM] isEqualToString:@"NO"]) {
                NSMutableDictionary *obj = [self.ssObjects[index] mutableCopy];
                obj[KEY_FOR_DATA] = image;
                obj[KEY_FOR_THUM] = @"YES";
                self.ssObjects[index] = [obj copy];
                // save thumb image to disk.
                [SSFile saveThumbImage:image ofHash:obj[KEY_FOR_HASH]];
            }
            return image;
        };
    } else if (type == kDataTypeText) {
        textView.text = content;
    } else if (type == kDataTypeUnsupported) {
        //TODO: Other type to support
    }

//    [(ReflectionView *)view update];
    return view;
}


#pragma mark - CarouselDelegate

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    self.hashString = self.ssObjects[index][KEY_FOR_HASH];
    
    if (self.carousel.currentItemIndex == index && self.hashString) {
        NSString *path = [SSFile filePathOf:self.files.fileArray[index]];
        NSLog(@"Path String: %@, URL: %@",path, [NSURL fileURLWithPath:path isDirectory:NO]);
        self.imageURLToBeShownInFullScreen = [NSURL fileURLWithPath:path isDirectory:NO];
        [self performSegueWithIdentifier:@"Show Image In Full Screen" sender:carousel];
    }
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
    if (carousel.currentItemIndex != -1) {
        self.hashString = self.ssObjects[carousel.currentItemIndex][KEY_FOR_HASH];
        if (self.hashString || [self.hashString isEqualToString:@""])
            [self.sendButton setEnabled:YES];
    }
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    [self.sendButton setEnabled:NO];
}

//#pragma mark - TextViewControllerDelegate
//- (void)didFinishTextInput:(NSString *)inputText
//{
//    NSData *dataToSend = [inputText dataUsingEncoding:NSUTF8StringEncoding];
//    self.hashString = [[MD5 defaultMD5] md5ForData:dataToSend];
//    
//    [self _replaceObjectAfterAdding:inputText correspondingHash:self.hashString];
//    
//    [self _startNetworkingAndUpdateUI];
//    
//    if (self.bonjour.foundServices.count > 0) {
//        //        [self.bonjour sendData:dataToSend];
//    } else {
//        [[NetworkHelper helper] uploadData:dataToSend contentType:kDataTypeText WithHashString:self.hashString delegate:self];
//    }
//}


#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    DataType imageType;
    NSData* pictureData;
    NSString *picturePath;
    if (!image) image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeJPEG]
            || [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeJPEG2000]
            || [[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
            imageType = kDataTypeImageJPEG;
            pictureData = UIImageJPEGRepresentation(image, 1);
            picturePath = [SSFile saveFileToDocumentsOfName:@"Image.jpg" withData:pictureData];
        } else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypePNG]) {
            imageType = kDataTypeImagePNG;
            pictureData = UIImagePNGRepresentation(image);
            picturePath = [SSFile saveFileToDocumentsOfName:@"Image.png" withData:pictureData];
        }
    }
    
    // TODO
    // change photo size according to network.
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self _startNetworkingAndUpdateUI];
        self.hashString = [[MD5 defaultMD5] md5ForData:pictureData];
        
        if (self.bonjourIsOn && self.bonjour.foundServices.count > 0) {
            [self.bonjour sendFile:picturePath];
        }
        
        if (self.internetIsOn) {
            [[NetworkHelper helper] uploadData:pictureData contentType:kDataTypeImageJPEG WithHashString:self.hashString delegate:self];
        }
        [self _replaceObjectAfterAdding:image correspondingHash:self.hashString];
    }];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return self;
}

#pragma mark - View Controller Life Cycle
#define CORNER_RADIUS 8.0f
#define SHADOW_OPACITY 0.75f
#define SHADOW_RADIUS 6.0f

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    //Settings of views in this controller
//    self.sendButton.layer.borderColor = [UIColor redColor].CGColor;
//    self.sendButton.layer.borderWidth = 2.0f;
    
    //*********** programmtically add button to bottomToolbar ***********
    self.addButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add.png"]];
    UIButtonWithLargerTapArea *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = self.addButtonImageView.bounds;
    [button addSubview:self.addButtonImageView];
    [button addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    NSMutableArray *toolbarItems = [self.bottomToolbar.items mutableCopy];
    [toolbarItems addObject:barButtonItem];
    self.bottomToolbar.items = toolbarItems;
    
//    UIBarButtonItem *tempBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
////    tempBarButtonItem.image = [UIImage imageNamed:@"add.png"];
//    tempBarButtonItem.style = UIBarButtonItemStyleBordered;
//    self.barToTransform = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    self.barToTransform.items = [NSArray arrayWithObject:tempBarButtonItem];
//    
//    UIBarButtonItem *barButtonItemInToolbar = [[UIBarButtonItem alloc] initWithCustomView:self.barToTransform];
//    NSMutableArray *toolbarItems2 = [self.bottomToolbar.items mutableCopy];
//    [toolbarItems2 addObject:barButtonItemInToolbar];
//    self.bottomToolbar.items = toolbarItems2;
    //
    
    //*********** Waveform related *********** 
    self.waveform.layer.cornerRadius = CORNER_RADIUS;
    self.waveform.layer.masksToBounds = YES;
//    self.waveform.layer.shadowOpacity = SHADOW_OPACITY;
//    self.waveform.layer.shadowRadius = SHADOW_RADIUS;
//    self.waveform.layer.shadowColor = [UIColor blackColor].CGColor;
    self.waveform.dataSource = self;
    //Waveform End.
    
    //*********** Sound related initialization. *********** 
    [SoundGenerator defaultGenerator].delegate = self;
    [SoundReceiver defaultReceiver].delegate = self;
    [SoundReceiver defaultReceiver].shouldAnalyze = YES;
    self.hasSample = NO;
    //Sound End
    
    //*********** Content Initialization *********** 
    //No Content Image, need to change in the future
//    NSDictionary *dic1 = @{KEY_FOR_TYPE: @(kDataTypeImageJPEG), KEY_FOR_DATA:[UIImage imageNamed:@"NoImage.png"]};
//    NSDictionary *dic2 = @{KEY_FOR_TYPE: @(kDataTypeImageJPEG), KEY_FOR_DATA:[UIImage imageNamed:@"NoImage.png"]};
//    NSDictionary *dic3 = @{KEY_FOR_TYPE: @(kDataTypeImageJPEG), KEY_FOR_DATA:[UIImage imageNamed:@"NoImage.png"]};
//    //Model of collection view cell. Also need to consider more carefully in the future.
//    NSMutableArray *temp = [NSMutableArray array];
//    [temp addObject:dic1];
//    [temp addObject:dic2];
//    [temp addObject:dic3];
//    self.ssObjects = temp;
    //The cell number, should be loaded from NSUserDefault.
//    self.cellNumber = 3;
    //Collection View End.
    
    //*********** Carousel ***********
    self.carousel.type = iCarouselTypeCoverFlow2;
    self.carousel.bounceDistance = 0.5;
    //delegate and datasource are set in storyboard.
//    self.carousel.dataSource = self;
//    self.carousel.delegate = self;
    //Carousel End
    
    //*********** Sidebar ***********
//    if (![self.slidingViewController.underRightViewController isKindOfClass:[SidebarViewController class]]) {
//        self.slidingViewController.underRightViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Sidebar"];
//        SidebarViewController *sidebarVC = (SidebarViewController *)self.slidingViewController.underRightViewController;
//        sidebarVC.delegate = self;
//    }
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
//    [self.slidingViewController setAnchorLeftRevealAmount:52.0f];
//    //Shadow
//    self.view.layer.shadowOpacity = 0.75f;
//    self.view.layer.shadowRadius = 10.0f;
//    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    //Sidebar End

    //*********** SSBonjour start ***********
    self.bonjour = [[SSBonjour alloc] initWithNone];
    self.bonjour.delegate = self;
    //SSBonjour end
    
    
    [[SoundReceiver defaultReceiver] startRecording];
    
    
    
    
    //TODO: Add method to join push notification server.
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    [self.carousel reloadData];
//    if (ABS([self.lastRefreshTime timeIntervalSinceNow]) > FIVE_MINUTES || !self.lastRefreshTime) {
//        self.lastRefreshTime = [NSDate date];
//        //Bonjour Service
//        self.serverBrowser = [[ServerBrowser alloc] init];
//        self.serverBrowser.delegate = self;
//        [self.serverBrowser start];
//        
//        //SVProgressHUD
//        [SVProgressHUD showWithStatus:SEARCH_SERVER maskType:SVProgressHUDMaskTypeBlack];
//        [self performSelector:@selector(_findServerTimeout) withObject:nil afterDelay:TIMEOUT_VALUE];
//    }
//}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//}

- (void)viewDidUnload
{
    //Should consider more about this
	AudioSessionSetActive(false);
}

#pragma mark -
#pragma mark Segue Related

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Image In Full Screen"]) {
        if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
            ImageViewController *ivc = (ImageViewController *)segue.destinationViewController;
            ivc.imageURL = self.imageURLToBeShownInFullScreen;
        }
    } else if ([segue.identifier isEqualToString:INPUT_TEXT_IDENTIFIER]) {
        // Dosen't need TextMessageVC's delegate, because it is implemented by unwind segue.
        TextMessageViewController *textMessageVC = (TextMessageViewController *)segue.destinationViewController;
        textMessageVC.delegate = self;
//        [self.slidingViewController resetTopView];
    }
}

#pragma mark TextMessageViewControllerUnwindSegue
//- (IBAction)doneTextInput:(UIStoryboardSegue *)segue
//{
//    TextMessageViewController *modalTMVC = (TextMessageViewController *)segue.sourceViewController;
//    NSString *resultText = modalTMVC.textView.text;
//}

- (void)doneWithTextInput:(NSString *)inputText
{
    NSData *dataToSend = [inputText dataUsingEncoding:NSUTF8StringEncoding];
    self.hashString = [[MD5 defaultMD5] md5ForData:dataToSend];
    
    [self _replaceObjectAfterAdding:inputText correspondingHash:self.hashString];
    
    [self _startNetworkingAndUpdateUI];
    
    if (self.bonjourIsOn && self.bonjour.foundServices.count > 0) {
        //TODO: send text through bonjour
    }
    
    if (self.internetIsOn) {
        [[NetworkHelper helper] uploadData:dataToSend contentType:kDataTypeText WithHashString:self.hashString delegate:self];
    }
}

#pragma mark SettingViewController Unwind Segue
- (IBAction)doneSetting:(UIStoryboardSegue *)segue
{
    
}

#pragma mark Others.

- (BOOL)shouldAutorotate
{
    return NO;
}



@end
