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
    // Since saveFileInfoOfPath:withHashString: is a class method, return the latest list everytime.
    return [[NSUserDefaults standardUserDefaults] arrayForKey:kFileList];
}

+ (NSString *)filePathOf:(NSDictionary *)ssfile
{
    return [ssfile valueForKey:kFilePath];
}

+ (NSString *)thumbPathOf:(NSDictionary *)ssfile
{
    return [[self class] thumbImagePath:[[self class] fileHashStringOf:ssfile]];
}

+ (NSData *)fileDataOf:(NSDictionary *)ssfile
{
    NSString *filePath;
    if ([[self class] hasThumbImage:ssfile]) {
        NSLog(@"Has thumb image");
        filePath = [[self class] thumbPathOf:ssfile];
    } else {
        filePath = [[self class] filePathOf:ssfile];
    }
    return [[NSFileManager defaultManager] contentsAtPath:filePath];
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

+ (BOOL)hasThumbImage:(NSDictionary *)ssfile
{    
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self class] thumbPathOf:ssfile]];
}

NSString * const kFilePath = @"SSKEY_FILE_PATH";
NSString * const kHashString = @"SSKEY_HASH_STRING";
NSString * const kFileList = @"SSKEY_FILE_LIST";

+ (NSString *)saveFileToDocumentsOfName:(NSString *)fileName withData:(NSData *)payloadData
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
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

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
+ (void)saveThumbImage:(UIImage *)thumbImage ofHash:(NSString *)hashString
{ 
    NSData *data = UIImagePNGRepresentation(thumbImage);
    
    NSString *thumbImagePath = [[self class] thumbImagePath:hashString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbImagePath]) {
        NSLog(@"Save thumb image %@ of %@", [[NSFileManager defaultManager] createFileAtPath:thumbImagePath
                                                                                    contents:data
                                                                                  attributes:nil]
              ? @"YES" : @"NO", hashString);
    }

}
#endif

+ (BOOL)createThumbDirectory
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:[[self class] thumbDirectoryPath] withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (BOOL)hasThumbDirectory
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[[self class] thumbDirectoryPath]];
}

+ (NSString *)thumbDirectoryPath
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    NSString *dirPath = [NSString stringWithFormat:@"%@/thumbs", [NSString documentsPath]];
    return dirPath;
#else
    return nil;
#endif
}

+ (NSString *)thumbImagePath:(NSString *)hashString
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    NSString *filePath = [NSString stringWithFormat:@"%@/thumbs/%@.png", [NSString documentsPath], hashString];
    return filePath;
#else
    return nil;
#endif
}

@end
