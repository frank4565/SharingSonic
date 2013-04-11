//
//  AFSharingSonicClient.m
//  MultimediaProject
//
//  Created by Cheng Junlu on 12/28/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "AFSharingSonicClient.h"
#import "AFHTTPRequestOperation.h"
#import "ServerBaseURL.h"

@implementation AFSharingSonicClient

+ (AFSharingSonicClient *)sharedClient
{
    static AFSharingSonicClient *_sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFSharingSonicClient alloc] initWithBaseURL:[NSURL URLWithString:kAFSharingSonicAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    return self;
}

@end
