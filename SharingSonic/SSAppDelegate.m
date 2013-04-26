//
//  SSAppDelegate.m
//  SharingSonic
//
//  Created by Cheng Junlu on 4/9/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSAppDelegate.h"
#import "PushNotificationSettings.h"
#import "SSFile.h"

@implementation SSAppDelegate

static NSString const * HAS_SET_SWITCH = @"Has set switch";
static NSString const *BONJOUR_SWITCH_VALUE = @"Bonjour switch value";
static NSString const *INTERNET_SWITCH_VALUE = @"Internet switch value";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (![SSFile hasThumbDirectory]) {
        [SSFile createThumbDirectory];
    }
    
    // Initialize the value of the switch in setting.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)HAS_SET_SWITCH]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:(NSString *)BONJOUR_SWITCH_VALUE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:(NSString *)INTERNET_SWITCH_VALUE];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:(NSString *)HAS_SET_SWITCH];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	// We have received a new device token. This method is usually called right
	// away after you've registered for push notifications, but there are no
	// guarantees. It could take up to a few seconds and you should take this
	// into consideration when you design your app. In our case, the user could
	// send a "join" request to the server before we have received the device
	// token. In that case, we silently send an "update" request to the server
	// API once we receive the token.
    
	NSString* oldToken = [PushNotificationSettings defaultSetting].deviceToken;
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My token is: %@", newToken);
    
    [PushNotificationSettings defaultSetting].deviceToken = newToken;
    
	// If the token changed and we already sent the "join" request, we should
	// let the server know about the new device token.
	if ([PushNotificationSettings defaultSetting].isJoined && ![newToken isEqualToString:oldToken])
	{
		[[PushNotificationSettings defaultSetting] postUpdateRequest];
	}
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

@end
