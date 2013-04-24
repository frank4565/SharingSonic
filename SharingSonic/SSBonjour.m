//
//  SSBonjour.m
//  MultimediaProject
//
//  Created by Cheng Junlu on 3/7/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import "SSBonjour.h"
#import "SSBonjourClient.h"
#import "SSBonjourServer.h"
#import "DTBonjourDataConnection.h"
#import "SSBonjourData.h"

@interface SSBonjour() <DTBonjourDataConnectionDelegate, DTBonjourServerDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (nonatomic, strong, readwrite) NSMutableArray *createdClients;
@property (nonatomic, strong, readwrite) SSBonjourServer *server;
@property (nonatomic, strong, readwrite) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, strong, readwrite) NSMutableSet *unidentifiedServices;
@property (nonatomic, strong, readwrite) NSMutableArray *foundServices;
@property (nonatomic, strong, readwrite) NSMutableArray *createdServers;
//@property (nonatomic, strong, readwrite) SSBonjourData *receivedSSData;
@end

@implementation SSBonjour

- (NSMutableArray *)createdClients
{
    if (!_createdClients) {
        _createdClients = [[NSMutableArray alloc] init];
    }
    return _createdClients;
}

- (SSBonjourServer *)server
{
    if (!_server) {
        _server = [[SSBonjourServer alloc] initWithNone];
        [self.createdServers addObject:_server];
        [_server start];
    }
    return _server;
}

- (NSMutableSet *)unidentifiedServices
{
    if (!_unidentifiedServices) {
        _unidentifiedServices = [[NSMutableSet alloc] init];
    }
    return _unidentifiedServices;
}

- (NSMutableArray *)foundServices
{
    if (!_foundServices) {
        _foundServices = [[NSMutableArray alloc] init];
    }
    return _foundServices;
}

- (NSMutableArray *)createdServers
{
    if (!_createdServers) {
        _createdServers = [[NSMutableArray alloc] init];
    }
    return _createdServers;
}

- (BOOL)_isLocalServiceIdentifier:(NSString *)identifier
{
	for (SSBonjourServer *server in self.createdServers)
	{
		if ([server.identifier isEqualToString:identifier])
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)_updateFoundServices
{
	for (NSNetService *service in [self.unidentifiedServices copy]) {
        if (![service.domain isEqualToString:@"local."]) {
            //            NSLog(@"willNotUpdateService: %@", service);
            continue;
        }
        
        //        NSLog(@"willUpdateService: %@", service);
        
		NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:service.TXTRecordData];
		
		if (!dict) {
            //            NSLog(@"!dict.didnotUpdateService: %@", service);
			continue;
		}
		
		NSString *identifier = [[NSString alloc] initWithData:dict[kIDENTIFIER] encoding:NSUTF8StringEncoding];
        
        if ([identifier isEqualToString:@""]) {
            //            NSLog(@"!identifier.didnotUpdateSerivce: %@", service);
            continue;
        }
        
        //        NSLog(@"%@ identifier = %@", service, identifier);
		
		if (![self _isLocalServiceIdentifier:identifier]) {
			[self.foundServices addObject:service];
            NSLog(@"updateService: %@", service);
            if ([self.delegate respondsToSelector:@selector(didAddNewBonjourService:)]) {
                [self.delegate didAddNewBonjourService:service];
            }
		} else {
            //            NSLog(@"didnotUpdateServices: %@", service);
        }
		
		[self.unidentifiedServices removeObject:service];
	}
}

- (id)initWithNone
{
    self = [super init];
    
    //Bonjour start
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser searchForServicesOfType:@"_SharingSonic._tcp" inDomain:@"local"];
    //Bonjour end
    
    //DTBonjour start
    self.server.delegate = self;
    //DTBonjour end
    
    return self;
}

- (void)_sendData:(NSData *)data
{
    for (NSNetService *service in self.foundServices) {
        SSBonjourClient *client = [[SSBonjourClient alloc] initWithService:service];
        client.delegate = self;
        [client open];
        
        NSError *error;
        [client sendObject:data error:&error];
        
        [self.createdClients addObject:client];
    }
}

- (void)sendFile:(NSString *)filePath
{
    SSBonjourData *ssData = [[SSBonjourData alloc] initWithFile:filePath];
	if (ssData.data) {
        [self _sendData:ssData.data];
    }
}

- (void)sendFile:(NSString *)filePath toServices:(NSNetService *)service
{
    SSBonjourData *ssData = [[SSBonjourData alloc] initWithFile:filePath];
	if (ssData.data) {
        [self _sendData:ssData.data];
        
        SSBonjourClient *client = [[SSBonjourClient alloc] initWithService:service];
        client.delegate = self;
        [client open];
        
        NSError *error;
        [client sendObject:ssData.data error:&error];
        
        [self.createdClients addObject:client];
    }
}

#pragma mark NetServiceBrowser Delegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    aNetService.delegate = self;
    [aNetService startMonitoring];
    
    [self.unidentifiedServices addObject:aNetService];
    
    //    NSLog(@"found: %@", aNetService);
    
    if (!moreComing) {
        [self _updateFoundServices];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
    [self.foundServices removeObject:aNetService];
	[self.unidentifiedServices removeObject:aNetService];
    //
    //	NSLog(@"removed: %@", aNetService);
    //
    //	if (!moreComing)
    //	{
    //		[self.tableView reloadData];
    //	}
}

#pragma mark - NSNetService Delegate
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data
{
	[self _updateFoundServices];
	
	[sender stopMonitoring];
}

#pragma mark - DTBonjourServer Delegate (Server)

- (void)bonjourServer:(DTBonjourServer *)server didReceiveObject:(id)object onConnection:(DTBonjourDataConnection *)connection
{
    if (![object isKindOfClass:[NSData class]]) {
        NSLog(@"ERROR! object is not NSData!");
        return;
    }
    
    SSBonjourData *receivedSSData = [[SSBonjourData alloc] initWithData:(NSData *)object];
    
//    [self.delegate downloadDidFinishWithData:object contentType:kDataTypeImageJPEG];
    [self.delegate downloadDidFinishWithFile:receivedSSData.filePath];
}

#pragma mark - DTBonjourConnection Delegate (Client)

- (void)connection:(DTBonjourDataConnection *)connection didFinishSendingChunk:(DTBonjourDataChunk *)chunk;
{
    SSBonjourClient *client = (SSBonjourClient *)connection;
    [client close];
}

- (void)connectionDidClose:(DTBonjourDataConnection *)connection
{
    //    NSLog(@"Close");
    SSBonjourClient *client = (SSBonjourClient *)connection;
    [self.createdClients removeObject:client];
    //    NSLog(@"%ld", [self.createdClients count]);
}

@end
