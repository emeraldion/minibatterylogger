//
//  MBLSharingService.m
//  MiniBatteryLogger
//
//  Created by delphine on 21-02-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import "MBLSharingService.h"

extern NSString *MBLAdvertiseServiceKey;
extern NSString *MBLRemoteBatteryMonitoringServiceType;
extern int MBLRemoteBatteryMonitoringPort;

@class AppController;

@protocol MBLSharingMaster;

@interface MBLSharingService (Private)

+ (void)_connectWithPorts:(NSArray *)portArray;

@end

@implementation MBLSharingService

+ (NSConnection *)startWorkerThreadMaster:(id)obj
{
	NSPort *port1 = [NSPort port];
	NSPort *port2 = [NSPort port];

	// Store in reverse order
	NSArray *portArray = [[NSArray arrayWithObjects:port2, port1, nil] retain];

	// Create the DO connection
	NSConnection *theConnection = [[NSConnection alloc] initWithReceivePort:port1 sendPort:port2];

	//NSLog(@"%@", obj);
	// Set the connection's root object
	[theConnection setRootObject:obj];
	
	// Start a new thread with the given selector
	[NSThread detachNewThreadSelector:@selector(_connectWithPorts:)
							 toTarget:self withObject:portArray];
	
	// Return the connection with retain count of 1
	return theConnection;
}

- (id)initForMaster:(id)theMaster
{
	if (self = [super init])
	{
		[self setMaster:theMaster];
		_shouldKeepRunning = NO;
	}
	return self;
}

- (void)setMaster:(id)theMaster
{
	[theMaster retain];
	[master release];
	master = theMaster;
}

- (void)setBatteryServer:(BatteryServer *)srv
{
	[srv retain];
	[batteryserver release];
	batteryserver = srv;
}

- (void)dealloc
{
	//NSLog(@"-[MBLSharingService dealloc]");
	[master release];
	[super dealloc];
}

- (void)performSelector:(SEL)selector target:(id)tgt withObject:(id)anObj
{
	if ([tgt respondsToSelector:selector])
	{
		[tgt performSelector:selector withObject:anObj];
	}
}

- (oneway void)start
{
	[[NSRunLoop currentRunLoop] run];
}

- (oneway void)stop
{
	//NSLog(@"Stopping worker thread");
	_shouldKeepRunning = NO;
}

- (oneway out BOOL)batteryServerRunning
{
	return [batteryserver isRunning];
}

- (oneway void)setBatteryServerPublishes:(oneway in BOOL)yorn
{
	if (yorn ^ [batteryserver publishes])
	{
		// Perform only if different from current settings
		[self stopBatteryServer];
		[batteryserver setPublishes:yorn];
		[self startBatteryServer];
	}
}

- (oneway void)startBatteryServer
{
	NSError * startError = nil;
	if (![batteryserver start:&startError])
	{
		NSLog(@"Error starting server: %@", startError);
	}
	else
	{
		NSLog(@"Starting server on port %d", [batteryserver port]);
	}	
}

- (oneway void)stopBatteryServer
{
	[batteryserver stop];	
}

@end

@implementation MBLSharingService (Private)

+ (void)_connectWithPorts:(NSArray *)portArray
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSConnection *myConnection = [NSConnection connectionWithReceivePort:[portArray objectAtIndex:0]
																sendPort:[portArray objectAtIndex:1]];
	
	id rootProxy = (id)[myConnection rootProxy];
	[rootProxy retain];
	[rootProxy setProtocolForProxy:@protocol(MBLSharingMaster)];
	
	MBLSharingService *service = [[self alloc] initForMaster:rootProxy];
	// The owner will retain the worker
	[rootProxy setSharingService:service];
	
	BatteryServer *batteryserver = [[BatteryServer alloc] init];

    [batteryserver setType:MBLRemoteBatteryMonitoringServiceType];
	[batteryserver setPort:MBLRemoteBatteryMonitoringPort];
	[batteryserver setServerName:[AppController applicationName]];
	[batteryserver setPublishes:[[[NSUserDefaults standardUserDefaults] objectForKey:MBLAdvertiseServiceKey] boolValue]];
	
	// Set server as service ivar
	[service setBatteryServer:batteryserver];

	// Start battery server
	[service startBatteryServer];
	
	// Start the work loop
	[service start];
	
	// We can safely release it
	[service release];
	
	[pool release];
}

@end