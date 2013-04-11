//
//  SSBonjourServer.m
//  SharingSonicMac
//
//  Created by Cheng Junlu on 2/28/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSBonjourServer.h"
#import "DTBonjourDataConnection.h"
#import "NSString+DTUTI.h"

@interface SSBonjourServer ()
@property (nonatomic, readwrite) NSString *identifier;
@end

@implementation SSBonjourServer

- (NSString *)identifier
{
    if (!_identifier) {
        
        // Moved the following code to NSString+DTUTI
        
//        // from https://github.com/Cocoanetics/DTFoundation/blob/master/Core/Source/NSString%2BDTUtilities.m
//        CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
//        
//        //get the string representation of the UUID
//        _identifier = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
//        CFRelease(uuidObj);
//        
//        //        NSLog(@"Created identifier: %@", _identifier);
        
        
        _identifier = [NSString stringWithUUID];
    }
    return _identifier;
}

- (id)initWithNone
{
    self = [super initWithBonjourType:@"_SharingSonic._tcp."];
    
    if (self)
    {
        [self _updateTXTRecord];
    }
    
    return self;
}

- (void)_updateTXTRecord
{
	self.TXTRecord = @{kIDENTIFIER : [self.identifier dataUsingEncoding:NSUTF8StringEncoding]};
}

- (void)connection:(DTBonjourDataConnection *)connection didReceiveObject:(id)object
{
	// need to call super because this forwards the object to the server delegate
	[super connection:connection didReceiveObject:object];
	
    //	// we need to pass the object to all other connections so that they also see the messages
    //	for (DTBonjourDataConnection *oneConnection in self.connections)
    //	{
    //		if (oneConnection!=connection)
    //		{
    //			[oneConnection sendObject:object error:NULL];
    //		}
    //	}
}

@end