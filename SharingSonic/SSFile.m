//
//  SSFile.m
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/16/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSFile.h"
#import "NSString+DTPaths.h"
#import "NSString+SSPaths.h"
#import "MD5.h"
#import "NSString+DTUTI.h"

@implementation SSFile

- (NSArray *)fileArray
{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kFileList];
}

+ (NSString *)filePathOf:(NSDictionary *)ssfile
{
    return [ssfile valueForKey:kFilePath];
}
 
+ (NSData *)fileDataOf:(NSDictionary *)ssfile
{
    return [[NSFileManager defaultManager] contentsAtPath:[[self class] filePathOf:ssfile]];
}

+ (NSString *)fileHashStringOf:(NSDictionary *)ssfile
{
    return [ssfile valueForKey:kHashString];
}

+ (DataType)fileDataTypeOf:(NSDictionary *)ssfile
{
    NSString *extension = [[[self class] filePathOf:ssfile] pathExtension];
    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];
    
    if (!uti) {
        return kDataTypeNoType;
    }
    
    if ([uti conformsToUniversalTypeIdentifier:(NSString *)kUTTypePNG]) {
        return kDataTypeImagePNG;
    }
    // for other type image such as tiff, use kUTTypeImage.
    if ([uti conformsToUniversalTypeIdentifier:(NSString *)kUTTypeImage]) {
        return kDataTypeImageJPEG;
    }
    if ([uti conformsToUniversalTypeIdentifier:(NSString *)kUTTypeText]) {
        return kDataTypeText;
    }
    // other types remain to support.
    return kDataTypeUnsupported;
}

NSString * const kFilePath = @"SSKEY_FILE_PATH";
NSString * const kHashString = @"SSKEY_HASH_STRING";
NSString * const kFileList = @"SSKEY_FILE_LIST";

+ (NSString *)saveFileToDocumentsOfName:(NSString *)fileName withData:(NSData *)payloadData
{
#if TARGET_IPHONE_SIMULATOR
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [NSString documentsPath], fileName];
#elif TARGET_OS_IPHONE
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [NSString documentsPath], fileName];
#else
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [NSString downloadsPath], fileName];
#endif
    
    // Write to storage
    while ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == YES) {
        //Rename it
        NSLog(@"Rename it");
        filePath = [filePath pathByIncrementingSequenceNumber];
    }
    NSLog(@"%@", filePath);
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:payloadData
                                          attributes:nil];
    
	// Reset the file's modification date.
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
    NSError *error;
	if (![[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:filePath error:&error]) {
        NSLog(@"%@", error);
	}
    
    NSString *hashString = [[MD5 defaultMD5] md5ForData:payloadData];
    if ([[self class] saveFileInfoOfPath:filePath withHashString:hashString]) {
        NSLog(@"Save to user defaults successfully.");
    } else {
        NSLog(@"Did not save to user defaults.");
    }
    
    return filePath;
}

+ (BOOL)saveFileInfoOfPath:(NSString *)path withHashString:(NSString *)hashString
{
    NSDictionary *dic =  @{kFilePath : path, kHashString : hashString};
    
    NSArray *files = [[NSUserDefaults standardUserDefaults] arrayForKey:kFileList];
    if (!files) {
        files = @[dic];
    } else {
        NSMutableArray *mutableFiles = [files mutableCopy];
        [mutableFiles addObject:dic];
        files = mutableFiles;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:files forKey:kFileList];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
