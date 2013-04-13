//
//  SSActiveLocationAnnotation.h
//  SharingSonic
//
//  Created by PowerQian on 4/13/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SSActiveLocationAnnotation : NSObject <MKAnnotation>

+ (SSActiveLocationAnnotation *)locationWithName:(NSString *)name city:(NSString *)city location:(CLLocation *)location;

@end
