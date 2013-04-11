//
//  NoteDictionary.h
//  MultimediaProject
//
//  Created by PowerQian on 11/15/12.
//  Copyright (c) 2012 PowerQian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteDictionary : NSObject

@property (strong,nonatomic) NSDictionary *noteDictionaryForHash;

+ (NoteDictionary *)defaultDictionary;

@end
