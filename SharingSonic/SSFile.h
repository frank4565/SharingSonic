//
//  SSFile.h
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/16/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataType.h"

@interface SSFile : NSObject

@property (nonatomic, strong, readonly) NSArray *fileArray;

+ (NSString *)filePathOf:(NSDictionary *)ssfile;

+ (NSData *)fileDataOf:(NSDictionary *)ssfile;

+ (NSString *)fileHashStringOf:(NSDictionary *)ssfile;

+ (DataType)fileDataTypeOf:(NSDictionary *)ssfile;

+ (BOOL)hasThumbImage:(NSDictionary *)ssfile;

+ (BOOL)createThumbDirectory;

+ (BOOL)hasThumbDirectory;

+ (BOOL)saveFileInfoOfPath:(NSString *)path withHashString:(NSString *)hashString;

+ (NSString *)saveFileToDocumentsOfName:(NSString *)fileName
                               withData:(NSData *)payloadData;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
+ (void)saveThumbImage:(UIImage *)thumbImage ofHash:(NSString *)hashString;
#endif

@end
