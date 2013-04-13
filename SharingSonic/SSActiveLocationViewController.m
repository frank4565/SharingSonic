//
//  SSActiveLocationViewController.m
//  SharingSonic
//
//  Created by PowerQian on 4/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSActiveLocationViewController.h"
#import <MapKit/MapKit.h>

@interface SSActiveLocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL isLocationServiceEnabled;
@end

@implementation SSActiveLocationViewController

#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@",userLocation);
}


#pragma mark - CLLocationManagerDelegate

- (void)_showLocationServiceNotAvailableAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Location service is disabled! Please turn on Location Service to use this function" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        [self _showLocationServiceNotAvailableAlert];
        [self.locationManager stopUpdatingLocation];
        self.mapView.showsUserLocation = NO;
    } else {
        NSLog(@"Other error: %@",error);
    }
}


#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        
        self.isLocationServiceEnabled = YES;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
        self.mapView.showsUserLocation = YES;
    } else if (self.view) {
        [self _showLocationServiceNotAvailableAlert];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
