//
//  PushNotificationSettings.h
//  MultimediaProject
//
//  Created by PowerQian on 4/6/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationSettings : NSObject

// The codes are modified from an example.
// I dosen't change the basic structure of code since
// the php code on the server requires those fields,
// which are in the database.

// @deviceToken and uuid are what they are.

// @message can be the message of Push Notification,
// i.e. the content of Push.

// @secretCode can be the code used by the same WLAN,
// i.e. devices can receive the Push from other devices in the same WLAN.

// @isJoined indicates whether or not the device has joined the Push server.

// @name can be the bonjour name.

@property (nonatomic, strong)           NSString *deviceToken;
@property (nonatomic, readonly, strong) NSString *openUdid;
@property (nonatomic, readonly, strong) NSString *message;
@property (nonatomic, strong)           NSString *secretCode;
@property (nonatomic, strong)           NSString *name;
@property (nonatomic)                   BOOL     isJoined;

- (void)postUpdateRequest;

+ (PushNotificationSettings *)defaultSetting;

@end
