//
//  SSBonjourData.m
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSBonjourData.h"
#import "NSScanner+DTBonjour.h"
#import "NSString+DTPaths.h"
#import "NSString+DTUTI.h"
#import "SSFile.h"

@interface SSBonjourData()
@property (nonatomic, strong, readwrite) NSData *data;
@property (nonatomic, assign) NSRange rangeOfHeader;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *fileType;
@property (nonatomic, assign) NSUInteger fileLength;
@property (nonatomic, assign) NSUInteger totalBytes;
@property (nonatomic, strong, readwrite) NSString *filePath;
@end

@implementation SSBonjourData

#pragma mark - Receiving Data

- (BOOL)_hasCompleteHeader
{
	// find end of header, \r\n\r\n
	NSData *headerEnd = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
	
	NSRange headerEndRange = [self.data rangeOfData:headerEnd options:0 range:NSMakeRange(0, [_data length])];
	
	if (headerEndRange.location == NSNotFound)
	{
		// we don't have a complete header
		return NO;
	}
	
	// update the range
	self.rangeOfHeader = NSMakeRange(0, headerEndRange.location + headerEndRange.length);
	
	return YES;
}

- (void)_decodeHeader
{
//	NSAssert(self.rangeOfHeader.length>0, @"Don't decode header if range is unknown yet");
	
	NSString *string = [[NSString alloc] initWithBytesNoCopy:(void *)[_data bytes] length:self.rangeOfHeader.length encoding:NSUTF8StringEncoding freeWhenDone:NO];
	
	if (!string)
	{
		NSLog(@"Error decoding header, not a valid NSString");
		return;
	}
	
	NSScanner *scanner = [NSScanner scannerWithString:string];
	scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	if (![scanner scanString:@"PUT" intoString:NULL])
	{
		return;
	}
	
	NSDictionary *headers;
	if (![scanner scanBonjourConnectionHeaders:&headers])
	{
		return;
	}
    
    self.fileName = headers[@"File-Name"];
	
	self.fileType = headers[@"File-Type"];
    
    self.fileLength = [headers[@"File-Length"] longLongValue];
    
	self.totalBytes = self.rangeOfHeader.length + self.fileLength;
}

- (NSString *)_decodedFile
{
	NSInteger indexAfterHeader = NSMaxRange(self.rangeOfHeader);
	NSRange payloadRange = NSMakeRange(indexAfterHeader, self.fileLength);
	NSData *payloadData = [self.data subdataWithRange:payloadRange];
    self.data = payloadData;
	
	return [SSFile saveFileToDocumentsOfName:self.fileName withData:payloadData];
}

#pragma mark - Initializer

- (id)initWithFile:(NSString *)filePath
{
    self = [super init];
    
    self.filePath = filePath;
    self.fileName = filePath.pathComponents.lastObject;
    self.fileType = [NSString universalTypeIdentifierForFileExtension:filePath.pathExtension];
    
    //encode File
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
	self.fileLength = fileData.length;

    //encode Header
    NSString *header = [NSString stringWithFormat:@"PUT\r\nFile-Name: %@\r\nFile-Type: %@\r\nFile-Length:%ld\r\n\r\n", self.fileName, self.fileType, (long)fileData.length];
	NSData *headerData = [header dataUsingEncoding:NSUTF8StringEncoding];
    
	self.rangeOfHeader = NSMakeRange(0, headerData.length);
	
	self.totalBytes = self.rangeOfHeader.length + self.fileLength;
    
    //encode frame data
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:self.totalBytes];
	
	[data appendData:headerData];
	[data appendData:fileData];
    
    self.data = data;
    
    return self;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    
    self.data = data;
    if ([self _hasCompleteHeader]) {
        [self _decodeHeader];
    }
    self.filePath = [self _decodedFile];
    
    return self;
}

@end
