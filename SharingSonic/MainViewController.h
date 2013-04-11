//
//  MainViewController.h
//  MultimediaProject
//
//  Created by PowerQian on 1/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BasicParameters.h"
#import "NetworkHelper.h"
#import "ECSlidingViewController.h"
#import "SidebarViewController.h"
#import "SonicTableView.h"
#import "SoundGenerator.h"
#import "SoundReceiver.h"
#import "WaveView.h"
#import "iCarousel.h"

@interface MainViewController : UIViewController
<NetworkHelperDelegate,
SoundGeneratorDelegate,SoundReceiverDelegate,
WaveViewDataSource,
iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet WaveView *waveform;

@property (strong,nonatomic) NSString *hashString;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openinButton;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;
//for CollectionView
@property (strong, nonatomic) NSMutableArray *ssObjects;
@property (nonatomic) NSUInteger cellNumber;

@end
