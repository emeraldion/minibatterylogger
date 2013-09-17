//
//  BatteryServer.h
//  MiniBatteryLogger
//
//  Created by delphine on 31-03-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TCPServer.h"
#import "LocalBatteryManager.h"
#import "DemoBatteryManager.h"
#import "Battery+ServerAdditions.h"

extern const NSString *kMBLServerSignatureHeaderKey;
extern const NSString *kMBLBatteryCountHeaderKey;
extern const NSString *kMBLMachineTypeHeaderKey;
extern const NSString *kMBLServiceUIDHeaderKey;

@interface BatteryServer : TCPServer {
	@private
    CFMutableDictionaryRef connections;
	NSMutableArray *_batteryManagers;
	NSMutableData *_dataBuffer;
	NSString *_serverName;
}

- (void)write:(NSString *)str toStream:(NSStream *)ostream;
- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;

/*!
 @method serverSignature
 @abstract Returns the server signature header for the response.
 */
- (NSString *)serverSignature;

/*!
 @method serverStatus:details:
 @abstract Returns the server status header for the response.
 @param status An integer status code.
 @param details A short description of the status.
 */
- (NSString *)serverStatus:(int)code details:(NSString *)details;

/*!
 @method setBatteryManagers:
 @abstract Sets the battery managers for the receiver.
 @discussion Use this method to set an array of local battery managers for the server.
 @param managers An array of battery managers.
 */
- (void)setBatteryManagers:(NSArray *)managers;

/*!
 @method batteryManagers
 @abstract Returns the battery managers of the receiver.
 @result An array of battery managers.
 */
- (NSArray *)batteryManagers;

/*!
 @method setServerName:
 @abstract Sets the receiver's server name.
 @discussion Since the BatteryServer class can be executed from several different contexts,
 this parameter lets you specify the context in which the server is being run.
 @param name The name of the server.
 */
- (void)setServerName:(NSString *)name;

/*!
 @method serverName
 @abstract Returns the receiver's server name.
 @discussion Since the BatteryServer class can be executed from several different contexts,
 this parameter lets you specify the context in which the server is being run.
 @result The name of the server.
 */
- (NSString *)serverName;

@end