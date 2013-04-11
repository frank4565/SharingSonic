//
//  AFSharingSonicClient.h
//  MultimediaProject
//
//  Created by Cheng Junlu on 12/28/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFSharingSonicClient : AFHTTPClient
+ (AFSharingSonicClient *)sharedClient;
@end
