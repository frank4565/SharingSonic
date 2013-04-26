//
//  SSSettingTableViewController.m
//  SharingSonic
//
//  Created by PowerQian on 4/26/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSSettingTableViewController.h"

static NSString const *BONJOUR_SWITCH_VALUE = @"Bonjour switch value";
static NSString const *INTERNET_SWITCH_VALUE = @"Internet switch value";

@interface SSSettingTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *bonjourSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *internetSwitch;

@end

@implementation SSSettingTableViewController

- (IBAction)bonjourSwitchChanged:(UISwitch *)sender {
    NSLog(@"Bonjour switch state: %c",sender.on);
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:(NSString *)BONJOUR_SWITCH_VALUE];
}

- (IBAction)internetSwitchChanged:(UISwitch *)sender {
    NSLog(@"Internet switch state: %c",sender.on);
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:(NSString *)INTERNET_SWITCH_VALUE];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.bonjourSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)BONJOUR_SWITCH_VALUE]];
    [self.internetSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:(NSString *)INTERNET_SWITCH_VALUE]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
