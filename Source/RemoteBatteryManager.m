//
//  RemoteBatteryManager.m
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "RemoteBatteryManager.h"
#import "Battery+ServerAdditions.h"
#import "BatteryEvent+ServerAdditions.h"
#import "BatteryServer.h"
#import <netinet/in.h>
#import <netdb.h>

NSString *MBLBatteryManagerAuthorizationRequiredNotification = @"MBLBatteryManagerAuthorizationRequired";
NSString *MBLBatteryManagerRemoteConnectionErrorNotification = @"MBLBatteryManagerRemoteConnectionError";

static NSString *MBLConnectingToRemoteMachine;

@interface RemoteBatteryManager (Private)

- (void)_connect;
- (void)_consumeBatteryEvent:(BatteryEvent *)evt;
- (void)_sendRemoteRequest:(id)arg;
- (void)_handleNotification:(NSNotification *)notif;
- (void)_processReceivedData;
- (void)_setMachineTypeFromServerResponse:(NSString *)response;
- (void)_setServiceUIDFromServerResponse:(NSString *)response;

void _remoteBatteryManagerSocketCallBack (
					  CFSocketRef s,
					  CFSocketCallBackType callbackType,
					  CFDataRef address,
					  const void *data,
					  void *info
					  );
@end

@implementation RemoteBatteryManager

+ (void)initialize
{
	MBLConnectingToRemoteMachine = NSLocalizedString(@"Connecting...", @"Connecting...");
}

- (id)initWithRemoteAddress:(NSString *)address port:(int)port index:(int)index
{
	if (self = [super init])
	{
		[self setAddress:address];
		[self setPort:port];
		[self setIndex:index];
		[self setMachineType:MBLConnectingToRemoteMachine];
		[self probeBattery];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLStartMonitoringAtLaunchKey] boolValue])
		{
			[self startMonitoring];
		}
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_handleNotification:)
													 name:MBLProbeIntervalChangedNotification
												   object:nil];
	}
	return self;
}

- (id)initWithRemoteAddress:(NSString *)address index:(int)index
{
	return [self initWithRemoteAddress:address port:4153 index:index];
}

- (void)dealloc
{
	//NSLog(@"-[%@ dealloc]", [self class]);
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self stopMonitoring];
	[_address release];
	[_dataBuffer release];
	[super dealloc];
}

- (void)setAddress:(NSString *)address
{
	[address retain];
	[_address release];
	_address = address;
}

- (NSString *)address
{
	return _address;
}

- (void)setPort:(int)port
{
	if (port > 0)
	{
		_port = port;
	}
}

- (int)port
{
	return _port;
}

- (id)name
{
	return [NSArray arrayWithObjects:_address, _machineType, nil];
}

- (void)probeBattery
{
	//NSLog(@"-[%@ probeBattery]", [self class]);
	[NSThread detachNewThreadSelector:@selector(_sendRemoteRequest:)
							 toTarget:self
						   withObject:nil];
}

- (void)startMonitoring
{
	if (_monitoring)
		return;
	
	int interval = [[[NSUserDefaults standardUserDefaults] objectForKey:MBLProbeIntervalKey] intValue];
	
	if (interval > 0)
	{
		_pollTimer = [[NSTimer scheduledTimerWithTimeInterval:interval
													   target:self
													 selector:@selector(probeBattery)
													 userInfo:NULL
													  repeats:YES] retain];
		
		[self setMonitoring:YES];
	}
}

- (void)stopMonitoring
{
	if (!_monitoring)
		return;
	[_pollTimer invalidate];
	_pollTimer = nil;
	[self setMonitoring:NO];
}

@end

@implementation RemoteBatteryManager (Private)

- (void)_consumeBatteryEvent:(BatteryEvent *)evt
{
	//NSLog(@"[%@] Consuming BatteryEvent (%@)", [self class], evt);
	
	[super _consumeBatteryEvent:evt];
	
	[_battery setCharge:[evt charge]];
	[_battery setPlugged:[evt isPlugged]];
	[_battery setCharging:[evt isCharging]];
	[_battery setCapacity:[evt capacity]];
	[_battery setMaxCapacity:[evt maxCapacity]];
	[_battery setAbsoluteMaxCapacity:[evt absoluteMaxCapacity]];
	[_battery setAmperage:[evt amperage]];
	[_battery setCycleCount:[evt cycleCount]];
	[_battery setVoltage:[evt voltage]];
	[_battery setTimeToEmpty:[evt timeToEmpty]];
	[_battery setTimeToFullCharge:[evt timeToFullCharge]];
	
	// Wrap event in a notification
	NSNotification *notif = [NSNotification notificationWithName:MBLBatteryPropertiesChangedNotification
														  object:self
														userInfo:(void *)evt];
	// Post the notification to the default center
	[[NSNotificationCenter defaultCenter] postNotification:notif];
}

- (void)_handleNotification:(NSNotification *)notif
{
	if ([[notif name] isEqualToString:MBLProbeIntervalChangedNotification])
	{
		if (_monitoring)
		{
			// Stop and restart; this will force to reload the new interval value
			[self stopMonitoring];
			[self startMonitoring];
		}
	}
}

- (void)_sendRemoteRequest:(id)arg
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	CFSocketRef			battSocket;
	CFSocketSignature	sockSignature;
	struct sockaddr_in	remote_addr;
	struct hostent		*host;
	CFDataRef			address;
	CFOptionFlags		callBackTypes;
	CFRunLoopSourceRef	source;
	CFRunLoopRef		loop;
	//struct servent		*service;
	
	if (!(host = gethostbyname([[self address] UTF8String])))
	{
		perror("gethostbyname");
		exit(1);
	}
		
	remote_addr.sin_family = AF_INET;
	remote_addr.sin_port = htons(_port);
	bcopy(host->h_addr, &(remote_addr.sin_addr.s_addr), host->h_length);
	
	// A CFSocketSignature structure fully specifies a CFSocket's
	// communication protocol and connection address
	sockSignature.protocolFamily = PF_INET;
	sockSignature.socketType = SOCK_STREAM;
	sockSignature.protocol = IPPROTO_TCP;
	address = CFDataCreate(kCFAllocatorDefault,
						   (UInt8 *)&remote_addr,
						   sizeof(remote_addr));
	sockSignature.address = address;
	
	// This is a variant of the read callback (kCFSocketReadCallBack): it
	// reads incoming data in the background and gives it to us packaged
	// as a CFData by invoking our callback
	callBackTypes = kCFSocketDataCallBack;
	
	CFSocketContext socketContext;
	socketContext.version = 0;
	socketContext.info = (void *)self;
	socketContext.retain = NULL;
	socketContext.release = NULL;
	socketContext.copyDescription = NULL;
	battSocket = CFSocketCreateConnectedToSocketSignature(kCFAllocatorDefault,	// allocator to use
														  &sockSignature,		// address and protocol
														  callBackTypes,		// activity type we are interested in
														  _remoteBatteryManagerSocketCallBack,		// call this function
														  &socketContext,			// context
														  10.0);				// timeout (in seconds)
	if (battSocket == NULL)
	{
		NSLog(@"-[%@ _sendRemoteRequest] Can't connect to %@", [self class], _address);
		[[NSNotificationCenter defaultCenter] postNotificationName:MBLBatteryManagerRemoteConnectionErrorNotification
															object:self];
	}
	else
	{
		source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, battSocket, 0);
		loop = CFRunLoopGetCurrent();
		CFRunLoopAddSource(loop, source, kCFRunLoopDefaultMode);
		
		CFDataRef sendData = CFStringCreateExternalRepresentation (
																   kCFAllocatorDefault,	// Allocator
																   (CFStringRef)[NSString stringWithFormat:@"GET %d\r\n", _index + 1],	// CFStringRef
																   kCFStringEncodingUTF8,	// Encoding
																   0);						// Pass zero to stop when data conversion occurs
		
		CFSocketError err = CFSocketSendData (battSocket,	// The socket
											  NULL,				// Use socket's address
											  sendData,			// CFDataRef
											  10.0);				// Timeout

		switch (err)
		{
			case kCFSocketSuccess:
				CFRunLoopRunInMode(kCFRunLoopDefaultMode,
								   10.0,
								   false);
				break;
			case kCFSocketError:
				NSLog(@"-[%@ _sendRemoteRequest] There was an error connecting to %@", [self class], _address);
				break;
			case kCFSocketTimeout:
				NSLog(@"-[%@ _sendRemoteRequest] Timeout while connecting to %@", [self class], _address);
				break;
		}

		// Cleanup
		CFRelease(sendData);	
		CFRelease(source);
		CFRelease(battSocket);
	}
	CFRelease(address);
		
	[pool release];
}

- (void)_connect
{
}

- (void)_setMachineTypeFromServerResponse:(NSString *)response
{
	//NSLog(@"Acquiring machine type");
	NSString *type;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	if ([scanner scanUpToString:kMBLMachineTypeHeaderKey intoString:NULL] &&
		[scanner scanString:kMBLMachineTypeHeaderKey intoString:NULL] &&
		[scanner scanString:@":" intoString:NULL] &&
		[scanner scanUpToString:@"\r\n" intoString:&type])
	{
		[self setMachineType:type];
		
		// Post a notification with the changed property name
		[[NSNotificationCenter defaultCenter] postNotificationName:MBLBatteryManagerPropertiesChangedNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
																							   forKey:@"machineType"]];	
	}
}

- (void)_setServiceUIDFromServerResponse:(NSString *)response
{
	NSString *uid;
	NSScanner *scanner = [NSScanner scannerWithString:response];
	if ([scanner scanUpToString:kMBLServiceUIDHeaderKey intoString:NULL] &&
		[scanner scanString:kMBLServiceUIDHeaderKey intoString:NULL] &&
		[scanner scanString:@":" intoString:NULL] &&
		[scanner scanUpToString:@"\r\n" intoString:&uid])
	{
		[self setServiceUID:uid];
		
		// Post a notification with the changed property name
		[[NSNotificationCenter defaultCenter] postNotificationName:MBLBatteryManagerPropertiesChangedNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
																							   forKey:@"serviceUID"]];
	}
}	

- (void)_processReceivedData
{
	// We've got the carriage return at the end of the echo. Let's set the string.
	NSString *response = [[NSString alloc] initWithData:(NSData *)_dataBuffer encoding:NSUTF8StringEncoding];
	
	// Set machine type
	if ([[self machineType] isEqualToString:MBLConnectingToRemoteMachine])
	{
		[self _setMachineTypeFromServerResponse:response];
	}
	// Set service UID
	if (![self serviceUID])
	{
		[self _setServiceUIDFromServerResponse:response];
	}
	// Set one-time battery properties
	if ([_battery deviceName] == nil)
	{
		[_battery setPropertiesFromServerResponse:response];
	}
	
	// Build battery event with response
	BatteryEvent *event = [BatteryEvent batteryEventWithServerResponse:response];
	
	// Cleanup
	[response release];
	[_dataBuffer release];
	_dataBuffer = nil;
	
	// ...and consume it
	[self _consumeBatteryEvent:event];
}

void _remoteBatteryManagerSocketCallBack (
				 CFSocketRef s,
				 CFSocketCallBackType callbackType,
				 CFDataRef address,
				 const void *data,
				 void *info
				 )
{
	RemoteBatteryManager *manager = (RemoteBatteryManager *)info;

	if (CFDataGetLength((CFDataRef)data) > 0)
	{
		if (!manager->_dataBuffer) {
			manager->_dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
		}
		[manager->_dataBuffer appendData:(NSData *)data];
	}
	else
	{
		[manager _processReceivedData];
	}
}

@end