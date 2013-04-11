//
//  TextMessageViewController.m
//  MultimediaProject
//
//  Created by PowerQian on 12/26/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import "TextMessageViewController.h"

@interface TextMessageViewController () <UITextViewDelegate>


@end

@implementation TextMessageViewController

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
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)done:(UIBarButtonItem *)sender {
    [self.textView resignFirstResponder];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

@end
