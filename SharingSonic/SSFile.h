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

+ (BOOL)saveFileInfoOfPath:(NSString *)path withHashString:(NSString *)hashString;

+ (NSString *)saveFileToDocumentsOfName:(NSString *)fileName
                               withData:(NSData *)payloadData;

@end
