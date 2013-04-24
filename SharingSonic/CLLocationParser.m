//
//  CLLocationParser.m
//  FinalProjectDemo
//
//  Created by Li QIAN on 3/15/12.
//  Copyright (c) 2012 Tongji University. All rights reserved.
//

#import "CLLocationParser.h"

@implementation CLLocationParser

+ (NSString *)stringForLocation:(CLLocation *)location
{
    return [location description];
}


+ (CLLocation *)locationForString:(NSString *)locationString
{
    NSString *stringToParse = [locationString copy];
    int commarIndex = 0;
    int rightAngleBracketsIndex = 0;
    for (int i = 0 ; i < [stringToParse length]; i++) {
        if ([stringToParse characterAtIndex:i] == ',') {
            commarIndex = i;
            continue;
        }
        if ([stringToParse characterAtIndex:i] == '>') {
            rightAngleBracketsIndex = i;
            break;
        }
    }
    CLLocationDegrees latitude = [[stringToParse substringWithRange:NSMakeRange(1, commarIndex-1)] doubleValue];
    CLLocationDegrees longitude = [[stringToParse substringWithRange:NSMakeRange(commarIndex+1, rightAngleBracketsIndex-commarIndex)] doubleValue];
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

@end
