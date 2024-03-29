//
//  SSStatusBarControllerViewController.m
//  SharingSonicMac
//
//  Created by Cheng Junlu on 1/16/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSStatusBarController.h"
#import "SSDragStatusView.h"
#import "MD5.h"
#import "SSBonjour.h"

@interface SSStatusBarController () <SSDragStatusViewDelegate>
@property (nonatomic, strong) NSMutableArray *sonicData;
@property (nonatomic, assign) Float32 *sampleData;
// Bonjour
@property (nonatomic, strong) SSBonjour *bonjour;
@end

@implementation SSStatusBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:1];
        [nibBundleOrNil loadNibNamed:nibNameOrNil owner:self topLevelObjects:&muArray];
    }
    
    return self;
}

- (void)awakeFromNib
{
    //SoundReceiver start
    [SoundReceiver defaultReceiver].delegate = self;
    [[SoundReceiver defaultReceiver] startRecording];
    [SoundReceiver defaultReceiver].shouldAnalyze = YES;
    //SoundReceiver end
    
    //StatusBarItem start
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    SSDragStatusView *dragView = [[SSDragStatusView alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];
    dragView.statusItem = self.statusItem;
    [dragView setMenu:self.statusMenu];
    [dragView setImage:[NSImage imageNamed:@"Heart"]];
    dragView.delegate = self;
    [self.statusItem setView:dragView];
    //StatusBarItem end
    
    //SSBonjour start
    self.bonjour = [[SSBonjour alloc] initWithNone];
    self.bonjour.delegate = self;
    //SSBonjour end
    
}

#pragma mark Lazy initializer

- (void)setHashString:(NSString *)hashString
{
    if (_hashString != hashString) {
        _hashString = hashString;
        NSLog(@"Current Hash String: %@", self.hashString);
    }
}

#pragma mark NetworkHelperDelegate

- (void)uploadDidFinish
{
    //    [self _stopNetworkingAndUpdateUI];
    NSLog(@"Success!");
}

- (void)didSendDataLengthInTotal:(long long)totalSentLength withTotalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    //    float percentage = (float)totalSentLength / (float)totalBytesExpectedToWrite;
    //    [self.progressView setProgress:percentage animated:YES];
}

- (void)didReceiveDataLengthInTotal:(long long)totalReceivedLength withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead
{
    //    float percentage = (float)totalReceivedLength / (float)totalBytesExpectedToRead;
    //    [self.progressView setProgress:percentage animated:YES];
}

//- (void)downloadDidFinishWithData:(NSData *)data contentType:(DataType)type
//{
//    //    [self _stopNetworkingAndUpdateUI];
//    
//    if (type == kDataTypeImageJPEG || type == kDataTypeImagePNG) {
//        //        NSSonicData *newImage = [NSSonicData dataWithImage:[UIImage imageWithData:data]
//        //                                                      date:[NSDate dateWithTimeIntervalSinceNow:0]
//        //                                                      type:SonicTypePhoto];
//        //        [self _addObjectToSonicData:newImage];
////        self.imageView.image = [[NSImage alloc] initWithData:data];
//        [data writeToFile:[@"~/Downloads/image.jpg" stringByExpandingTildeInPath] atomically:NO];
//        
//    } else if (type == kDataTypeText) {
//        //        NSSonicData *newText = [NSSonicData dataWithText:[[NSString alloc] initWithData:data
//        //                                                                               encoding:NSUTF8StringEncoding]
//        //                                                    date:[NSDate dateWithTimeIntervalSinceNow:0]
//        //                                                    type:SonicTypeText];
//        //        [self _addObjectToSonicData:newText];
////        self.textView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    } else {
//        NSLog(@"Error occurs!");
//    }
//}

- (void)downloadDidFinishWithFile:(NSString *)filePath
{
    NSLog(@"%@", filePath);
}

- (void)failedWithError:(NSError *)error
{
    //    [self _stopNetworkingAndUpdateUI];
    
    //    if ([error code] == -1004) {
    //        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error occurs" message:@"Preparetion failed. Check your Network Status." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //        [errorAlert show];
    //    } else if ([error code] == -1002) {
    //        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error occurs" message:@"Server is not ready!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //        [errorAlert show];
    //        NSLog(@"%@",error);
    //    }
    
}

#pragma mark Core Function
//- (IBAction)addNewText:(id)sender
//{
//    [self didAddNewText:self.textView.string];
//    
//    [self share];
//}

//- (IBAction)addNewPhoto:(id)sender
//{
//    //NSImage to NSData in JPEG
//    NSBitmapImageRep *bmprep = [NSBitmapImageRep imageRepWithData:[self.imageView.image TIFFRepresentation]]; // TIFF representation data
//    NSDictionary *imageProperty = @{NSImageCompressionFactor : [NSNumber numberWithFloat:0.0]};
//    NSData *jpegImageData = [bmprep representationUsingType:NSJPEGFileType properties:imageProperty];
//    
//    [self didAddNewPhoto:self.imageView.image corespondingData:jpegImageData];
//    
//    [self share];
//}
//
////- (void)didAddNewText:(NSString *)text
////{
////    //    NSSonicData *newText = [NSSonicData dataWithText:text date:[NSDate dateWithTimeIntervalSinceNow:0] type:SonicTypeText];
////    //    [self _addObjectToSonicData:newText];
////    
////    NSData *dataToSend = [text dataUsingEncoding:NSUTF8StringEncoding];
////    self.hashString = [[MD5 defaultMD5] md5ForData:dataToSend];
////    
////    //    [self _startNetworkingAndUpdateUI];
////    [[NetworkHelper helper] uploadData:dataToSend contentType:kDataTypeText WithHashString:self.hashString delegate:self];
////}
//
//- (void)didAddNewPhoto:(NSImage *)image corespondingData:(NSData *)data
//{
//    //    NSSonicData *newPhoto = [NSSonicData dataWithImage:image date:[NSDate dateWithTimeIntervalSinceNow:0] type:SonicTypePhoto];
//    //    [self _addObjectToSonicData:newPhoto];
//    
//    self.hashString = [[MD5 defaultMD5] md5ForData:data];
//    
//    //    [self _startNetworkingAndUpdateUI];
//    [[NetworkHelper helper] uploadData:data contentType:kDataTypeImageJPEG WithHashString:self.hashString delegate:self];
//}

- (void)_didAddNewFileOfData:(NSData *)data
{
    self.hashString = [[MD5 defaultMD5] md5ForData:data];
    
//    if (self.bonjour.foundServices.count > 0) {
//        [self.bonjour sendData:data];
//    } else {
        [[NetworkHelper helper] uploadData:data contentType:kDataTypeImageJPEG WithHashString:self.hashString delegate:self];
//    }
}

- (void)_soundShare
{
    // Sound share
    if (self.hashString) {
        OSStatus err = [[SoundGenerator defaultGenerator] generateSoundOfHashString:self.hashString];
        if (err != noErr) {
            NSLog(@"Error occured : %d", err);
        } else {
            //            [sender setEnabled:NO];
            //            self.sendButton.alpha = 0.5;
        }
    } else {
        //        UIAlertView *addThings = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Nothing to send. Please add something" delegate:self cancelButtonTitle:@"I Know" otherButtonTitles:nil, nil];
        //        [addThings show];
//        NSLog(@"Nothing to send. Please add something");
    }
}

#pragma mark SoundReceiverDelegate

- (void)didGetResult:(NSString *)resultHashString
{
    NSLog(@"Get the analyzed result: %@",resultHashString);
    if (![self.hashString isEqualToString:resultHashString]) {
        self.hashString = resultHashString;
        //        [self _startNetworkingAndUpdateUI];
        
        //        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //        [indicator startAnimating];
        //        NSSonicData *newAcitivityIndicator = [[NSSonicData alloc] initWithView:indicator date:[NSDate dateWithTimeIntervalSinceNow:0] type:SonicTypeIndicator insets:UIEdgeInsetsMake(18, 15, 18, 15)];
        //        [self _addObjectToSonicData:newAcitivityIndicator];
        
        [[NetworkHelper helper] getDataOfHashString:self.hashString delegate:self];
    }
    
}

#pragma mark SSDragStatusViewDelegate

- (void)dragAndDropFile:(NSURL *)fileURL
{    
    if (self.bonjour.foundServices.count > 0) {
        [self.bonjour sendFile:fileURL.path];
    } else {
        NSData *data = [[NSData alloc] initWithContentsOfURL:fileURL];        
        [self _didAddNewFileOfData:data];
    }
       
    [self _soundShare];
}

@end
