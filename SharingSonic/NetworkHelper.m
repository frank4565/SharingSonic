//
//  NetworkHelper.m
//  MultimediaProject
//
//  Created by PowerQian on 11/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "NetworkHelper.h"
#import "ServerBaseURL.h"
#import "AFSharingSonicClient.h"
#import "AFHTTPRequestOperation.h"
#import "SSFile.h"

static NSString *constBoundry = @"0xKhTmLbOuNdArY";
static NSString * const pushServerSuffix = @"pushTest/api/api.php";

@implementation NetworkHelper

// POST BASE/query.php hash
// with hashString
- (void)getDataOfHashString:(NSString *)hashString delegate:(id <NetworkHelperDelegate>)delegate;
{
    self.delegate = delegate;

    [[AFSharingSonicClient sharedClient] setDefaultHeader:@"Content-Type" value:[@"boundray=" stringByAppendingString:constBoundry]];
    
    // As the totalBytesExpectedToRead will be -1 when using gzip,
    // in the response we disable the gzip encoding.
    [[AFSharingSonicClient sharedClient] setDefaultHeader:@"Accept-Encoding" value:@"compress"];
    
    NSURLRequest *request = [[AFSharingSonicClient sharedClient] requestWithMethod:@"POST" path:@"query.php" parameters:@{ @"hash" : hashString } ];
    AFHTTPRequestOperation *operation = [[AFSharingSonicClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DataType type = [self contentTypeOf:operation.response.MIMEType];
        NSString *file;
        if (type == kDataTypeImageJPEG || type == kDataTypeImagePNG) {
            file = @"Image.jpg";
        } else if (type == kDataTypeText) {
            file = @"Text.txt";
        }
        file = [SSFile saveFileToDocumentsOfName:file withData:(NSData *)responseObject];
//        [self.delegate downloadDidFinishWithData:(NSData *)responseObject contentType:type];
        [self.delegate downloadDidFinishWithData:(NSData *)responseObject ofFile:file];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error.domain == AFNetworkingErrorDomain && error.code == -1011) {
            [self.delegate failedWithStatus:@"Failed to fetch!"];
        }
    }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [self.delegate didReceiveDataLengthInTotal:totalBytesRead withTotalBytesExpectedToRead:totalBytesExpectedToRead];
    }];

    [[AFSharingSonicClient sharedClient] enqueueHTTPRequestOperation:operation];
}

// POST BASE/upload.php hash data fileName=@"data"
// with hashString and uploadData
- (void)uploadData:(NSData *)uploadData
       contentType:(DataType)dataType
    WithHashString:(NSString *)hashString
          delegate:(id <NetworkHelperDelegate>)delegate
{
    self.delegate = delegate;    
    
    [[AFSharingSonicClient sharedClient] setDefaultHeader:@"Content-Type" value:[@"multipart/form-data;boundray=" stringByAppendingString:constBoundry]];
    
    NSURLRequest *request = [[AFSharingSonicClient sharedClient] multipartFormRequestWithMethod:@"POST" path:@"upload.php" parameters:@{ @"hash" : hashString } constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:uploadData name:@"data" fileName:@"data" mimeType:[self contentTypeHeaderOf:dataType]];
    }];
    
    AFHTTPRequestOperation *operation = [[AFSharingSonicClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.delegate uploadDidFinish];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegate failedWithStatus:@"Failed to upload!"];
    }];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [self.delegate didSendDataLengthInTotal:totalBytesWritten withTotalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }];
    [[AFSharingSonicClient sharedClient] enqueueHTTPRequestOperation:operation];
}

//#if TARGET_OS_IPHONE

#pragma mark - Push Notification Helper

static NSString const *POST_KEY_CMD = @"cmd";
static NSString const *POST_KEY_UDID = @"udid";
static NSString const *POST_KEY_NAME = @"name";
static NSString const *POST_KEY_CODE = @"code";
static NSString const *POST_KEY_TOKEN = @"token";
static NSString const *POST_KEY_TEXT = @"text";

+ (void)_postToPushServerWithInfo:(NSDictionary *)info completionBlock:(void(^)())success
{
    NSURLRequest *request = [[AFSharingSonicClient sharedClient] requestWithMethod:@"POST" path:pushServerSuffix parameters:info];
    AFHTTPRequestOperation *operation = [[AFSharingSonicClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode != 200) {
            NSLog(@"Response Error, Status Code: %ld", (long)operation.response.statusCode);
        } else success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Join Push Server Failed, error: %@", error);
    }];
    [[AFSharingSonicClient sharedClient] enqueueHTTPRequestOperation:operation];
}

+(void)joinPushServerWithUdid:(NSString *)udid
                   secretCode:(NSString *)code
                         name:(NSString *)name
                  deviceToken:(NSString *)token
            completionHandler:(void(^)())completion
{
    NSDictionary *joinSettingDic = @{POST_KEY_CMD: @"join",
                                     POST_KEY_UDID: udid,
                                     POST_KEY_CODE: code,
                                     POST_KEY_NAME: name,
                                     POST_KEY_TOKEN: token};
    [self _postToPushServerWithInfo:joinSettingDic completionBlock:completion];
}

+(void)leavePushServerWithUdid:(NSString *)udid
             completionHandler:(void(^)())completion
{
    NSDictionary *leaveSettingDic = @{POST_KEY_CMD: @"leave",
                                      POST_KEY_UDID: udid};
    [self _postToPushServerWithInfo:leaveSettingDic completionBlock:completion];
}

+(void)updatePushServerWithUdid:(NSString *)udid
                    deviceToken:(NSString *)token
              completionHandler:(void(^)())completion
{
    NSDictionary *updateSettingDic = @{POST_KEY_CMD: @"update",
                                       POST_KEY_UDID: udid,
                                       POST_KEY_TOKEN: token};
    [self _postToPushServerWithInfo:updateSettingDic completionBlock:completion];
}

+(void)messagePushServerWithUdid:(NSString *)udid
                            text:(NSString *)text
               completionHandler:(void(^)())completion
{
    NSDictionary *messageSettingDic = @{POST_KEY_CMD: @"message",
                                        POST_KEY_UDID: udid,
                                        POST_KEY_TEXT: text};
    [self _postToPushServerWithInfo:messageSettingDic completionBlock:completion];
}

//#endif

#pragma mark - Helper Method
- (DataType)contentTypeOf:(NSString *)contentTypeHeader
{
    DataType downloadType;
    if (contentTypeHeader == nil) {
        downloadType = kDataTypeNoType;
    } else if ([contentTypeHeader isEqual:@"image/jpeg"]) {
        downloadType = kDataTypeImageJPEG;
    } else if ([contentTypeHeader isEqual:@"image/png"]) {
        downloadType = kDataTypeImagePNG;
    } else if ([contentTypeHeader isEqual:@"text/plain"]) {
        downloadType = kDataTypeText;
    } else {
        downloadType = kDataTypeUnsupported;
    }
    return downloadType;
}

- (NSString *)contentTypeHeaderOf:(DataType)contentType
{
    NSString *contentTypeHeader;
    if (contentType == kDataTypeImageJPEG) {
        contentTypeHeader = @"image/jpeg";
    } else if (contentType == kDataTypeImagePNG) {
        contentTypeHeader = @"image/png";
    } else if (contentType == kDataTypeText) {
        contentTypeHeader = @"text/plain";
    } else {
        contentTypeHeader = @"Not supported!";
    }
    return contentTypeHeader;
}


//Singleton using GCD
+ (NetworkHelper *)helper
{
    static NetworkHelper *defaultHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHelper = [[self alloc] init];
    });
    return defaultHelper;
}
//

@end
