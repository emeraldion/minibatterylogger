//
//  BonjourBatteryManager.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-05-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BonjourBatteryManager.h"
#import "Battery+ServerAdditions.h"
#import "BatteryEvent+ServerAdditions.h"
#import "BatteryServer.h"
#import <netinet/in.h>

static NSString *MBLUnnamedRemoteMachine;

@interface BonjourBatteryManager (Private)

- (void)_connect;
- (void)_openStreams;
- (void)_closeStreams;
- (void)_consumeBatteryEvent:(BatteryEvent *)evt;
- (void)_sendRemoteRequest:(id)arg;
- (void)_getServerInfo;
- (void)_handleNotification:(NSNotification *)notif;

void _bonjourBatteryManagerSocketCallBack (
					  CFSocketRef s,
					  CFSocketCallBackType callbackType,
					  CFDataRef address,
					  const void *data,
					  void *info
					  );
@end

@implementation BonjourBatteryManager

+ (void)initialize
{
	MBLUnnamedRemoteMachine = NSLocalizedString(@"Unknown", @"Unknown");
}

- (id)initWithService:(NSNetService *)srv index:(int)index;
{
	if (self = [super init])
	{
		_netService = [srv retain];
		[_netService setDelegate:self];
		_index = index;
		[self setMachineType:MBLUnnamedRemoteMachine];
		//[self _getServerInfo];
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

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self stopMonitoring];
	[self _closeStreams];
	[_dataBuffer release];
	
	[super dealloc];
}

- (id)name
{
	return [NSArray arrayWithObjects:[_netService name], _machineType, nil];
}

- (void)probeBattery
{
	//NSLog(@"-[%@ probeBattery]", [self class]);
	
	if ([_netService respondsToSelector:@selector(getInputStream:outputStream:)])
	{
		if ([_netService getInputStream:&_inputStream outputStream:&_outputStream])
		{
			[self _openStreams];
			
			[NSThread detachNewThreadSelector:@selector(_sendRemoteRequest:)
									 toTarget:self
								   withObject:nil];
		}	
	}
	else
	{
		//NSLog(@"%@", _netService);
		if ([[_netService addresses] count] > 0)
		{
			[self _connect];
		}
		else
		{
			// Launch a resolution; the service will call the delegate method when done
			[_netService resolve];
		}
	}
	
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

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
    NSInputStream *istream;
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable:;
            uint8_t buffer[2048];
            int actuallyRead = 0;
			
			istream = (NSInputStream *)aStream;
            if (!_dataBuffer) {
                _dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
            }
				actuallyRead = [istream read:(uint8_t *)buffer maxLength:2048];
            if (actuallyRead > 0) {
                [_dataBuffer appendBytes:buffer length:actuallyRead];
            }
				break;
        case NSStreamEventEndEncountered:;
			// We've got the carriage return at the end of the echo. Let's set the string.
			NSString *response = [[NSString alloc] initWithData:_dataBuffer encoding:NSUTF8StringEncoding];
			
			//NSLog(@"%@", response);
			if ([_machineType isEqualToString:MBLUnnamedRemoteMachine])
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
				if (!_serviceUID)
				{
					NSString *uid;
					//NSLog(@"Acquiring Service UID");
					NSScanner *scanner = [NSScanner scannerWithString:response];
					if ([scanner scanUpToString:kMBLServiceUIDHeaderKey intoString:NULL] &&
						[scanner scanString:kMBLServiceUIDHeaderKey intoString:NULL] &&
						[scanner scanString:@":" intoString:NULL] &&
						[scanner scanUpToString:@"\r\n" intoString:&uid])
					{
						[self setServiceUID:uid];
						//NSLog(@"<%@>", _serviceUID);
						
						// Post a notification with the changed property name
						[[NSNotificationCenter defaultCenter] postNotificationName:MBLBatteryManagerPropertiesChangedNotification
																			object:self
																		  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
																											   forKey:@"serviceUID"]];
					}
				}
				
				// Build battery event with response
				BatteryEvent *event = [BatteryEvent batteryEventWithServerResponse:response];
			
			// ...and consume it
			[self _consumeBatteryEvent:event];
			
			// Cleanup
			[response release];
			[_dataBuffer release];
			_dataBuffer = nil;
			
			// Close streams
            [self _closeStreams];
            break;
        case NSStreamEventHasSpaceAvailable:
        case NSStreamEventErrorOccurred:
        case NSStreamEventOpenCompleted:
        case NSStreamEventNone:
        default:
            break;
    }
}

@end

@implementation BonjourBatteryManager (Private)

- (void)_openStreams {
    [_inputStream retain];
    [_outputStream retain];
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}

- (void)_closeStreams {
    [_inputStream close];
    [_outputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    [_outputStream setDelegate:nil];
    [_inputStream release];
    [_outputStream release];
    _inputStream = nil;
    _outputStream = nil;
}

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
	
	// Request data from the remote battery
	NSString * stringToSend = [NSString stringWithFormat:@"GET %d\r\n", _index + 1];
	NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
	if (_outputStream) {
		//NSLog(@"Sending %@", stringToSend);
		int remainingToWrite = [dataToSend length];
		void *marker = (void *)[dataToSend bytes];
		while (0 < remainingToWrite) {
			int actuallyWritten = 0;
			actuallyWritten = [_outputStream write:marker maxLength:remainingToWrite];
			remainingToWrite -= actuallyWritten;
			marker += actuallyWritten;
		}
	}
	[pool release];
}

- (void)_getServerInfo
{
	//NSLog(@"-[%@ _getServerInfo]", [self class]);
	
	if ([_netService getInputStream:&_inputStream outputStream:&_outputStream])
	{
		[self _openStreams];
		
		// Request data from the remote battery
		NSString * stringToSend = [NSString stringWithFormat:@"INFO\r\n"];
		NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
		if (_outputStream) {
			//NSLog(@"Sending %@", stringToSend);
			int remainingToWrite = [dataToSend length];
			void *marker = (void *)[dataToSend bytes];
			while (0 < remainingToWrite) {
				int actuallyWritten = 0;
				actuallyWritten = [_outputStream write:marker maxLength:remainingToWrite];
				remainingToWrite -= actuallyWritten;
				marker += actuallyWritten;
			}
		}
	}	
}

- (void)_connect
{
	//NSLog(@"[_netService addresses]: %@", [_netService addresses]);
	NSData *remote_addr = [[_netService addresses] objectAtIndex:0];
	//NSLog(@"remote_addr:%@", remote_addr);
	/*
	 NSSocketNativeHandle nativeSocketHandle = [[[NSSocketPort alloc] initRemoteWithProtocolFamily:PF_INET
																						socketType:SOCK_STREAM
																						  protocol:IPPROTO_TCP
																						   address:remote_addr]
		 socket];
	 */
	
	CFSocketNativeHandle nativeSocketHandle = CFSocketCreate(kCFAllocatorDefault,
															 PF_INET,
															 SOCK_STREAM,
															 IPPROTO_TCP,
															 kCFSocketNoCallBack|kCFSocketReadCallBack|kCFSocketAcceptCallBack|kCFSocketDataCallBack|kCFSocketConnectCallBack|kCFSocketWriteCallBack,
															 _bonjourBatteryManagerSocketCallBack,
															 NULL);
	CFSocketConnectToAddress(nativeSocketHandle,
							 (CFDataRef)remote_addr,
							 30.0);
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &(CFReadStreamRef)_inputStream, &(CFWriteStreamRef)_outputStream);
	if (_inputStream && _outputStream)
	{
		CFReadStreamSetProperty((CFReadStreamRef)_inputStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		CFWriteStreamSetProperty((CFWriteStreamRef)_outputStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
		
		[self _openStreams];
		
		[NSThread detachNewThreadSelector:@selector(_sendRemoteRequest:)
								 toTarget:self
							   withObject:nil];
		// Cleanup
		CFRelease((CFReadStreamRef)_inputStream);
		CFRelease((CFWriteStreamRef)_outputStream);
	}
	else
	{
		// on any failure, need to destroy the CFSocketNativeHandle 
		// since we are not going to use it any more
		close(nativeSocketHandle);
	}
	
}

void _bonjourBatteryManagerSocketCallBack (
					  CFSocketRef s,
					  CFSocketCallBackType callbackType,
					  CFDataRef address,
					  const void *data,
					  void *info
					  )
{
	//NSLog(@"callbackType: %d", callbackType);
}

- (void)netServiceWillPublish:(NSNetService *)sender
{
	//NSLog(@"netServiceWillPublish:");
}

//  Called to notify the delegate object that the resolution was able to start successfully.
- (void)netServiceWillResolve:(NSNetService *)sender
{
	//NSLog(@"netServiceWillResolve:");
}

//  Called to notify the delegate object that an error occurred, supplying a numeric error code. This may be called long after a netServiceWillPublish: message has been delivered to the delegate.
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	//NSLog(@"netService:didNotPublish:");
}

//  Called to inform the delegate that an address was resolved.  The delegate should use [aNetService addresses] to find out what the addresses may be in order to connect to the discovered service. The NSNetService may get resolved more than once - a DNS rotary may yield different IP addresses on different resolution requests.  Truly robust clients may wish resolve again on error, or resolve more than once.
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	//NSLog(@"netServiceDidResolveAddress:");
	//[self _connect];
}

//  Called to inform the delegate that an error occurred during resolution of a given NSNetService.
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	//NSLog(@"netService:didNotResolve:");
}

//  Called to inform the delegate that a previously running publication or resolution request has been stopped.
- (void)netServiceDidStop:(NSNetService *)sender
{
	//NSLog(@"netServiceDidStop:");
}

@end