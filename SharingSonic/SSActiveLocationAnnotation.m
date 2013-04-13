//
//  SSActiveLocationAnnotation.m
//  SharingSonic
//
//  Created by PowerQian on 4/13/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSActiveLocationAnnotation.h"

@interface SSActiveLocationAnnotation()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) CLLocation *location;
@end

@implementation SSActiveLocationAnnotation

+ (SSActiveLocationAnnotation *)locationWithName:(NSString *)name city:(NSString *)city location:(CLLocation *)location
{
    SSActiveLocationAnnotation *locationAnnotation = [[SSActiveLocationAnnotation alloc] init];
    locationAnnotation.name = name;
    locationAnnotation.city = city;
    locationAnnotation.location = location;
    return locationAnnotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.city;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D newCo;
    newCo.longitude = self.location.coordinate.longitude;
    newCo.latitude = self.location.coordinate.latitude;
    return newCo;
}

@end
