//
//  TestPushViewController.m
//  MultimediaProject
//
//  Created by PowerQian on 4/7/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "TestPushViewController.h"
#import "PushNotificationSettings.h"
#import "NetworkHelper.h"

@interface TestPushViewController ()

@end

@implementation TestPushViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    PushNotificationSettings *setting = [PushNotificationSettings defaultSetting];
    setting.name = @"QIAN";
    setting.secretCode = @"TEST";
    [NetworkHelper joinPushServerWithUdid:setting.openUdid secretCode:setting.secretCode name:setting.name deviceToken:setting.deviceToken completionHandler:^(){
        NSLog(@"Joined");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPush:(UIButton *)sender {
    PushNotificationSettings *setting = [PushNotificationSettings defaultSetting];
    NSLog(@"OpenUDID: %@, MESSAGE: %@", setting.openUdid, setting.message);
    [NetworkHelper messagePushServerWithUdid:setting.openUdid text:setting.message completionHandler:^(){
        NSLog(@"Push sent!");
    }];
}
- (IBAction)dismiss:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
