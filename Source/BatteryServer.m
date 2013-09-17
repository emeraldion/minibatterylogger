//
//  BatteryServer.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-03-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatteryServer.h"
#import <Foundation/Foundation.h>
#import "CPSystemInformation.h"

#define MBL_BATTD_SERVER_SIGNATURE @"MiniBatteryLogger 1.6.3"

const int kMBLServerStatusOK						= 200;
const int kMBLServerStatusNotInitializedError		= 301;
const int kMBLServerStatusError						= 400;
const int kMBLServerStatusNoSuchBatteryError		= 401;
const int kMBLServerStatusNotEnoughArgumentsError	= 501;

/*!
 @const kMBLServerVerbGet
 @abstract Verb to request full info for a single battery.
 */
const NSString *kMBLServerVerbGet					= @"GET";

/*!
 @const kMBLServerVerbInfo
 @abstract Verb to request information on the server's environment.
 */
const NSString *kMBLServerVerbInfo					= @"INFO";

/*!
 @const kMBLServerVerbCount
 @abstract Verb to request the number of available batteries.
 */
const NSString *kMBLServerVerbCount					= @"COUNT";

/*!
 @const kMBLServerVerbQuit
 @abstract Verb to request the server to quit.
 */
const NSString *kMBLServerVerbQuit					= @"QUIT";

/*!
 @const kMBLServerVerbList
 @abstract Verb to request the list of available batteries.
 */
const NSString *kMBLServerVerbList					= @"LIST";

const NSString *kMBLServerSignatureHeaderKey		= @"Server";
const NSString *kMBLBatteryCountHeaderKey			= @"Battery-Count";
const NSString *kMBLMachineTypeHeaderKey			= @"Machine-Type";
const NSString *kMBLServiceUIDHeaderKey				= @"Service-UID";

@interface BatteryServer (Private)

- (void)handleCountRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream;
- (void)handleInfoRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream;
- (void)handleGetRequest:(int)index inputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream;
- (void)handleQuitRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream;
- (void)handleListRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream;
- (void)processRequest:(NSString *)request inputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream;

@end

@implementation BatteryServer

- (id)init
{
	if (self = [super init])
	{
		[self setServerName:MBL_BATTD_SERVER_SIGNATURE];
		
		int battery_count = [LocalBatteryManager installedBatteries];

		//NSLog(@"Hello! This is the battd server");
		//NSLog(@"I found %d batteries on this computer", battery_count);
		
		[self setBatteryManagers:[NSArray array]];
		int i;
		for (i = 0; i < battery_count; i++)
		{
			LocalBatteryManager *mgr = [[LocalBatteryManager alloc] initWithIndex:i];
			// Start monitoring (just in case)
			[mgr startMonitoring];
			// Don't care to log anyway
			[mgr setLogging:NO];
			[_batteryManagers insertObject:mgr
								   atIndex:i];
			
			[mgr release];
		}
		/*
		DemoBatteryManager *mgr = [[DemoBatteryManager alloc] init];
		[mgr startMonitoring];
		[_batteryManagers addObject:mgr];
		*/
	}
	return self;
}

- (void)dealloc
{
	CFRelease(connections);
	[_batteryManagers release];
	[_dataBuffer release];
	[_serverName release];
	
	[super dealloc];
}

- (void)setBatteryManagers:(NSArray *)managers
{
	[_batteryManagers autorelease];
	_batteryManagers = [managers mutableCopy];
}

- (NSArray *)batteryManagers
{
	return _batteryManagers;
}

- (void)setupInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream {
    [istream retain];
    [ostream retain];
    [istream setDelegate:self];
    [ostream setDelegate:self];
    [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    CFDictionarySetValue(connections, istream, ostream);
    [istream open];
    [ostream open];
    //NSLog(@"Added connection.");
}

- (void)shutdownInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream {
    [istream close];
    [ostream close];
    [istream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [ostream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [istream setDelegate:nil];
    [ostream setDelegate:nil];
    CFDictionaryRemoveValue(connections, istream);
    [istream release];
    [ostream release];
    //NSLog(@"Connection closed.");
}

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
	//NSLog(@"New connection from address %@", addr);
    if (!connections) {
        connections = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    [self setupInputStream:istr outputStream:ostr];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    NSInputStream * istream;
    NSOutputStream * ostream;
    switch(streamEvent)
	{
        case NSStreamEventHasBytesAvailable:;
            istream = (NSInputStream *)aStream;
            ostream = (NSOutputStream *)CFDictionaryGetValue(connections, istream);

			uint8_t oneByte;
            int actuallyRead = 0;
            if (!_dataBuffer)
			{
				_dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
            }
			actuallyRead = [istream read:&oneByte maxLength:1];
            if (actuallyRead == 1)
			{
                [_dataBuffer appendBytes:&oneByte length:1];
            }
			if (oneByte == '\n')
			{
				NSString *request = [[NSString alloc] initWithData:_dataBuffer encoding:NSUTF8StringEncoding];
				
				//NSLog(@"Request: <%@>", request);				
				[self processRequest:request inputStream:istream outputStream:ostream];

				// Cleanup
				[_dataBuffer release];
                _dataBuffer = nil;
				
				// Close connection
				[self shutdownInputStream:istream outputStream:ostream];
            }
                break;
        case NSStreamEventEndEncountered:;
            istream = (NSInputStream *)aStream;
            ostream = nil;
            if (CFDictionaryGetValueIfPresent(connections, istream, (const void **)&ostream)) {
                [self shutdownInputStream:istream outputStream:ostream];
            }
                break;
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventErrorOccurred:
        case NSStreamEventOpenCompleted:
        case NSStreamEventNone:
        default:
            break;
    }
}

- (void)write:(NSString *)str toStream:(NSStream *)ostream
{
	[(NSOutputStream *)ostream write:[str UTF8String] maxLength:[str length]];
}

- (NSString *)serverSignature
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLServerSignatureHeaderKey, _serverName];
}

- (NSString *)serverStatus:(int)code details:(NSString *)details
{
	return [NSString stringWithFormat:@"%d %@\r\n",
		code, details];
}

- (void)setServerName:(NSString *)name
{
	[name retain];
	[_serverName release];
	_serverName = name;
}

- (NSString *)serverName
{
	return _serverName;
}

@end

@implementation BatteryServer (Private)

- (void)handleCountRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream
{
	[self handleInfoRequestInputStream:istream outputStream:ostream];
}

- (void)handleInfoRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream
{
	[self write:[self serverStatus:kMBLServerStatusOK details:@"Ok"] toStream:ostream];
	[self write:[self serverSignature] toStream:ostream];
	[self write:[NSString stringWithFormat:@"%@: %@\r\n", kMBLMachineTypeHeaderKey, [[CPSystemInformation machineType] substringFromIndex:1]]
	   toStream:ostream];	
	[self write:[NSString stringWithFormat:@"%@: %d\r\n", kMBLBatteryCountHeaderKey, [_batteryManagers count]]
	   toStream:ostream];
}

- (void)handleGetRequest:(int)index inputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream
{
	if (NSLocationInRange(index, NSMakeRange(1, [_batteryManagers count])))
	{
		Battery *batt = [[_batteryManagers objectAtIndex:index - 1] battery];
		
		[self write:[self serverStatus:kMBLServerStatusOK details:@"Ok"] toStream:ostream];
		[self write:[self serverSignature] toStream:ostream];
		[self write:[NSString stringWithFormat:@"%@: %@\r\n", kMBLMachineTypeHeaderKey, [[CPSystemInformation machineType] substringFromIndex:1]]
		   toStream:ostream];
		[self write:[NSString stringWithFormat:@"%@: %@\r\n", kMBLServiceUIDHeaderKey, [[_batteryManagers objectAtIndex:index - 1] serviceUID]]
		   toStream:ostream];
		
		/* Write battery properties */
		[self write:[batt capacityResponseHeader] toStream:ostream];
		[self write:[batt designCapacityResponseHeader] toStream:ostream];
		[self write:[batt chargeResponseHeader] toStream:ostream];
		[self write:[batt cycleCountResponseHeader] toStream:ostream];
		[self write:[batt voltageResponseHeader] toStream:ostream];
		[self write:[batt amperageResponseHeader] toStream:ostream];				
		[self write:[batt chargingResponseHeader] toStream:ostream];				
		[self write:[batt pluggedResponseHeader] toStream:ostream];
		[self write:[batt maxCapacityResponseHeader] toStream:ostream];				
		[self write:[batt timeToEmptyResponseHeader] toStream:ostream];				
		[self write:[batt timeToFullChargeResponseHeader] toStream:ostream];
		
		if ([batt deviceName] != nil)
		{
			[self write:[batt deviceNameResponseHeader] toStream:ostream];
			[self write:[batt manufacturerResponseHeader] toStream:ostream];
			[self write:[batt manufactureDateResponseHeader] toStream:ostream];
			[self write:[batt serialResponseHeader] toStream:ostream];
		}
	}
	else
	{
		[self write:[self serverStatus:kMBLServerStatusNoSuchBatteryError details:@"No such battery"] toStream:ostream];
	}
}

- (void)handleQuitRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream
{
	// Do nothing, connection will be closed automatically after the request has been served.
}

- (void)handleListRequestInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream
{
	[self write:[self serverStatus:kMBLServerStatusOK details:@"Ok"] toStream:ostream];
	[self write:[self serverSignature] toStream:ostream];
	[self write:[NSString stringWithFormat:@"%@: %@\r\n", kMBLMachineTypeHeaderKey, [[CPSystemInformation machineType] substringFromIndex:1]]
	   toStream:ostream];
	
	int i;
	for (i = 0; i < [_batteryManagers count]; i++)
	{
		[self write:[NSString stringWithFormat:@"%d %@\r\n", (i + 1), [[_batteryManagers objectAtIndex:i] serviceUID]]
		   toStream:ostream];		
	}
}

- (void)processRequest:(NSString *)request inputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream
{
	NSScanner *reqScanner = [NSScanner scannerWithString:request];
	
	NSString *verb;
	BOOL noMoreArgs = NO;
	if ([request rangeOfString:@" "].length > 0)
	{
		[reqScanner scanUpToString:@" " intoString:&verb];
	}
	else if ([request rangeOfString:@"\r"].length > 0 &&
			 [request length] > 2)
	{
		[reqScanner scanUpToString:@"\r" intoString:&verb];
	}
	else if (![request isEqualToString:@"\r\n"])
	{
		verb = request;
		noMoreArgs = YES;
	}
	else
	{
		// Nothing to do here
		return;
	}
	
	if ([[verb uppercaseString] isEqualToString:kMBLServerVerbCount])
	{
		[self handleCountRequestInputStream:istream outputStream:ostream];
	}
	else if ([[verb uppercaseString] isEqualToString:kMBLServerVerbInfo])
	{
		[self handleInfoRequestInputStream:istream outputStream:ostream];
	}
	else if ([[verb uppercaseString] isEqualToString:kMBLServerVerbList])
	{
		[self handleListRequestInputStream:istream outputStream:ostream];
	}
	else if ([[verb uppercaseString] isEqualToString:kMBLServerVerbGet])
	{
		int index;
		if ([reqScanner scanInt:&index])
		{
			[self handleGetRequest:index inputStream:istream outputStream:ostream];
		}
		else
		{
			[self write:[self serverStatus:kMBLServerStatusNotEnoughArgumentsError details:@"Not enough arguments"] toStream:ostream];
		}
	}
	else if ([[verb uppercaseString] isEqualToString:kMBLServerVerbQuit])
	{
		[self handleQuitRequestInputStream:istream outputStream:ostream];
	}
	else
	{
		[self write:[self serverStatus:kMBLServerStatusError details:@"Not understood"] toStream:ostream];
	}
}

@end