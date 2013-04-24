//
//  SSActiveLocationViewController.m
//  SharingSonic
//
//  Created by PowerQian on 4/12/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSActiveLocationViewController.h"
#import "NSString+DTPaths.h"
#import "CLLocationParser.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

static NSString const *LOCATION_FILE_NAME = @"LocationArray";
static NSString const *KEY_NAME = @"Location Name";
static NSString const *KEY_PLACEMARK = @"Placemar Name";
static NSString const *KEY_LOCATION = @"Location";

@interface SSActiveLocationViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) IBOutletCollection(id) NSArray *addLocationControlSet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addLocationBarButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong, readonly) NSArray *annotations; // of SSActiveLocationAnnotation
@property (nonatomic, strong, readonly) NSArray *annotationPropertyList;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastUserLocation;
@property (nonatomic, strong) NSString *currentPlacemark;
@property (nonatomic) BOOL isLocationServiceEnabled;
@end

@implementation SSActiveLocationViewController

- (void)reloadMapView
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.annotations];
}

- (NSString *)_locationFilePath
{
    return [NSString stringWithFormat:@"%@/%@", [NSString documentsPath], LOCATION_FILE_NAME];
}

- (BOOL)_saveLocationArray:(NSArray *)locationArray
{
    NSMutableArray *arrayToSave = [[NSMutableArray alloc] initWithCapacity:[locationArray count]];
    for (SSActiveLocationAnnotation *locAnn in locationArray) {
        NSDictionary *locDic = @{KEY_NAME: locAnn.title, KEY_PLACEMARK: locAnn.subtitle, KEY_LOCATION: [CLLocationParser stringForLocation:[[CLLocation alloc] initWithLatitude:locAnn.coordinate.latitude longitude:locAnn.coordinate.longitude]]};
        [arrayToSave addObject:locDic];
    }
    return [arrayToSave writeToFile:[self _locationFilePath] atomically:YES];
}

- (NSArray *)annotationPropertyList{
    NSArray *locationArray = [NSArray arrayWithContentsOfFile:[self _locationFilePath]];
    return locationArray;
}

- (NSArray *)annotations
{
    NSMutableArray *locationAnnotation = [[NSMutableArray alloc] initWithCapacity:[self.annotationPropertyList count]];
    for (NSDictionary *dic in self.annotationPropertyList) {
        SSActiveLocationAnnotation *locAnn = [SSActiveLocationAnnotation locationWithName:dic[KEY_NAME] city:dic[KEY_PLACEMARK] location:[CLLocationParser locationForString:dic[KEY_LOCATION]]];
        [locationAnnotation addObject:locAnn];
    }
    return locationAnnotation;
}

#pragma mark - MKMapViewDelegate
- (CLLocationDistance)significantDistance
{
    return 1000;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@",userLocation);
    if ( !self.lastUserLocation
        || [userLocation.location.timestamp timeIntervalSinceDate:self.lastUserLocation.timestamp] > 60
        || [userLocation.location distanceFromLocation:self.lastUserLocation] > [self significantDistance]) {
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemark, NSError *error){
            NSLog(@"Placemark: %@",[[placemark lastObject] name]);
            NSLog(@"Error: %@", error);
            self.currentPlacemark = [[placemark lastObject] name];
        }];
    }
    NSLog(@"Last Location Timestamp:%@, current timestamp:%@, timeInterval:%f",self.lastUserLocation.timestamp, userLocation.location.timestamp,[userLocation.location.timestamp timeIntervalSinceDate:self.lastUserLocation.timestamp] );
    self.lastUserLocation = userLocation.location;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"MapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    else if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
    }
    return view;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    MKAnnotationView *aV;
    
    for (aV in views) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options: UIViewAnimationOptionCurveLinear animations:^{
            
            aV.frame = endFrame;
            
            // Animate squash
        }completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                    
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.annotations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ActiveLocation";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    SSActiveLocationAnnotation *annotation = self.annotations[indexPath.row];
    cell.textLabel.text = annotation.title;
    cell.detailTextLabel.text = annotation.subtitle;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Registered Location:";
    } else
        return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSActiveLocationAnnotation *selectedLocation = self.annotations[indexPath.row];
    [self.mapView setCenterCoordinate:selectedLocation.coordinate animated:YES];
}


#pragma mark - Target/Action
- (IBAction)addLocation:(UIBarButtonItem *)sender {
    [sender setEnabled:NO];
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    for (UIControl *control in self.addLocationControlSet) {
        [control.layer addAnimation:animation forKey:nil];
        control.hidden = NO;
    }
}

- (IBAction)cancelAdd:(UIButton *)sender {
    [self.addLocationBarButton setEnabled:YES];
    [self.locationTextField resignFirstResponder];
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    for (UIControl *control in self.addLocationControlSet) {
        [control.layer addAnimation:animation forKey:nil];
        control.hidden = YES;
    }
}

- (IBAction)confirmLocation:(UIButton *)sender {
    NSString *locationName = self.locationTextField.text;
    NSMutableArray *tempLocArray = [self.annotations mutableCopy];
    if (!tempLocArray) {
        tempLocArray = [[NSMutableArray alloc] init];
    }
    SSActiveLocationAnnotation *newLoc = [SSActiveLocationAnnotation locationWithName:locationName city:self.currentPlacemark location:self.lastUserLocation];
    [tempLocArray addObject:newLoc];
    if (![self _saveLocationArray:tempLocArray]) {
        NSLog(@"Write to file failed");
    }
    [self.tableView reloadData];
    
    [self cancelAdd:nil]; // Same visual effect
    [self reloadMapView];
}


#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self reloadMapView];
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
