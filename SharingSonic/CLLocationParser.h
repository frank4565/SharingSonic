//
//  CLLocationParser.h
//  FinalProjectDemo
//
//  Created by Li QIAN on 3/15/12.
//  Copyright (c) 2012 Tongji University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocationParser : NSObject

+ (NSString *)stringForLocation:(CLLocation *)location;
+ (CLLocation *)locationForString:(NSString *)locationString;

@end
