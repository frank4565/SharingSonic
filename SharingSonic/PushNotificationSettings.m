//
//  PushNotificationSettings.m
//  MultimediaProject
//
//  Created by PowerQian on 4/6/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "PushNotificationSettings.h"
#import "ServerBaseURL.h"
#import "OpenUDID.h"

static NSString * const DeviceTokenKey = @"DeviceToken";
static NSString * const IsJoinedKey = @"IsJoined";
static NSString * const SecretCodeKey = @"SecretCode";
static NSString* const NameKey = @"Name";

@implementation PushNotificationSettings

@synthesize deviceToken = _deviceToken;
@synthesize isJoined = _isJoined;
@synthesize name = _name;
@synthesize secretCode = _secretCode;

+ (void)initialize
{
	if (self == [PushNotificationSettings class])
	{
		// Register default values for our settings
		[[NSUserDefaults standardUserDefaults] registerDefaults:
                                               @{DeviceTokenKey: @"0",
                                                    IsJoinedKey: @NO,
                                                  SecretCodeKey: @"",
                                                        NameKey: @"",}];
    }
}

static NSString * const pushMessage = @"You have a new thing!";

- (NSString *)message
{
    return pushMessage;
}

- (NSString *)name
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:NameKey];
}

- (void)setName:(NSString *)name
{
    if (_name != name) {
        _name = name;
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:NameKey];
    }
}

- (NSString *)secretCode
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:SecretCodeKey];
}

- (void)setSecretCode:(NSString *)string
{
    if (_secretCode != string) {
        _secretCode = string;
        [[NSUserDefaults standardUserDefaults] setObject:string forKey:SecretCodeKey];
    }
}

- (BOOL)isJoined
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SecretCodeKey];
}

- (void)setIsJoined:(BOOL)isJoined
{
    if (_isJoined != isJoined) {
        _isJoined = isJoined;
        [[NSUserDefaults standardUserDefaults] setBool:isJoined forKey:SecretCodeKey];
    }
}

- (NSString *)deviceToken
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:DeviceTokenKey];
}

- (void)setDeviceToken:(NSString *)deviceToken
{
    if (_deviceToken != deviceToken) {
        _deviceToken = deviceToken;
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DeviceTokenKey];
    }
}

- (NSString *)openUdid
{
    // Retrieve the OpenUDID and remove the "-"
    return [[OpenUDID value] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (void)postUpdateRequest
{
    //TODO: Change the following codes to AFNetworking codes
    
//    NSURL* url = [NSURL URLWithString:ServerApiURL];
//    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
//    [request setPostValue:@"update" forKey:@"cmd"];
//    [request setPostValue:[dataModel udid] forKey:@"udid"];
//    [request setPostValue:[dataModel deviceToken] forKey:@"token"];
//    [request setDelegate:self];
//    [request startAsynchronous];
}

+ (PushNotificationSettings *)defaultSetting
{
    static PushNotificationSettings *defaultPushNotificationSetting = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultPushNotificationSetting = [[self alloc] init];
    });
    return defaultPushNotificationSetting;
}

@end
