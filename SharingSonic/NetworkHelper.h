//
//  NetworkHelper.h
//  MultimediaProject
//
//  Created by PowerQian on 11/27/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataType.h"

@protocol NetworkHelperDelegate <NSObject>

- (void)uploadDidFinish;

- (void)downloadDidFinishWithData:(NSData *)data ofFile:(NSString *)filePath;

@optional
- (void)uploadDidReceiveResponse;
- (void)downloadDidReceiveResponseWithContentType:(DataType)type;
- (void)failedWithStatus:(NSString *)errorStatus;
- (void)didSendDataLengthInTotal:(long long)totalSentLength withTotalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite;
- (void)didReceiveDataLengthInTotal:(long long)totalReceivedLength withTotalBytesExpectedToRead:(long long)totalBytesExpectedToRead;

@optional
- (void)didAddNewBonjourService:(NSNetService *)service;

@end

@interface NetworkHelper : NSObject <NSURLConnectionDelegate>

- (void)getDataOfHashString:(NSString *)hashString
                   delegate:(id <NetworkHelperDelegate>)delegate;

- (void)uploadData:(NSData *)uploadData
       contentType:(DataType)dataType
    WithHashString:(NSString *)hashString
          delegate:(id <NetworkHelperDelegate>)delegate;

//#if TARGET_OS_IPHONE
// Helper method for interact with push server
+(void)joinPushServerWithUdid:(NSString *)udid
                   secretCode:(NSString *)code
                         name:(NSString *)name
                  deviceToken:(NSString *)token
            completionHandler:(void(^)())completion;

+(void)leavePushServerWithUdid:(NSString *)udid
             completionHandler:(void(^)())completion;

+(void)updatePushServerWithUdid:(NSString *)udid
                    deviceToken:(NSString *)token
              completionHandler:(void(^)())completion;

+(void)messagePushServerWithUdid:(NSString *)udid
                            text:(NSString *)text
               completionHandler:(void(^)())completion;
//#endif

@property (weak,nonatomic) id <NetworkHelperDelegate> delegate;

+ (NetworkHelper *)helper;

@end
