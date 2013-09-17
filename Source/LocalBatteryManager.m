//
//  LocalBatteryManager.m
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

static int _LocalBatteryManagerInstalledBatteries = -1;

#import "LocalBatteryManager.h"
#import "BatteryEvent.h"
#import "SleepEvent.h"
#import "WakeUpEvent.h"
#import "CPSystemInformation.h"
#import "MonitoringSession.h"
#import <IOKit/pwr_mgt/IOPM.h>

#define kMBLAppleSmartBatteryManagerName "AppleSmartBatteryManager"
#define kMBLAppleSmartBatteryName "AppleSmartBattery"

@interface NSCalendarDate (BatteryDates)

- (id)initWithBatteryManufactureDate:(int)dateMask;
+ (NSCalendarDate *)dateWithBatteryManufactureDate:(int)dateMask;

@end

@implementation NSCalendarDate (BatteryDates)

/**
 * Manufactured Date
 * Type: unsigned 16-bit bitfield
 * IORegistry Key: kIOPMPSManufactureDateKey
 * Date is published in a bitfield per the Smart Battery Data spec rev 1.1 
 * in section 5.1.26
 *   Bits 0...4 => day (value 1-31; 5 bits)
 *   Bits 5...8 => month (value 1-12; 4 bits)
 *   Bits 9...15 => years since 1980 (value 0-127; 7 bits)
 */
- (id)initWithBatteryManufactureDate:(int)dateMask
{
	int dayOfMonth = dateMask & 31;
	int month = (dateMask >> 5) & 15;
	int yearsFrom1980 = dateMask >> 9;
	
	return [self initWithYear:1980 + yearsFrom1980
						month:month
						  day:dayOfMonth
						 hour:0
					   minute:0
					   second:0
					 timeZone:nil];
}

+ (NSCalendarDate *)dateWithBatteryManufactureDate:(int)dateMask
{
	return [[self alloc] initWithBatteryManufactureDate:dateMask];
}

@end

@interface LocalBatteryManager (Private)

- (void)_initBatteryProperties;
- (void)_consumeBatteryEvent:(BatteryEvent *)evt;
- (NSDictionary *)_batteryProperties;
- (void)_handleCallback;
- (void)_startPollTimer;
- (void)_stopPollTimer;
- (void)_handleSleepWakeShutdown:(NSNotification *)note;
- (void)_handleNotification:(NSNotification *)notif;

void storeCallBack( SCDynamicStoreRef    store,
					CFArrayRef changedKeys,
					void *info);

@end

@implementation LocalBatteryManager

+ (int)installedBatteries
{
	if (_LocalBatteryManagerInstalledBatteries == -1)
	{
		mach_port_t master_device_port;
		kern_return_t kr;
		CFArrayRef battery_info;
		
		kr = IOMasterPort(bootstrap_port, &master_device_port);
		if ( kr == kIOReturnSuccess )
		{
			if(kIOReturnSuccess != IOPMCopyBatteryInfo(master_device_port, &battery_info))
			{
				NSLog(@"Failed to obtain battery info. Are you sure that this computer has a battery?\n");
				_LocalBatteryManagerInstalledBatteries = 0;
			}
			else
			{
				_LocalBatteryManagerInstalledBatteries = CFArrayGetCount(battery_info);
				CFRelease(battery_info);
			}
		}
	}
	return _LocalBatteryManagerInstalledBatteries;
}

- (id)initWithIndex:(int)index
{
	if (self = [super init])
	{
		[self _initBatteryProperties];

		[self setIndex:index];

		[self setMachineType:[[CPSystemInformation machineType] substringFromIndex:1]];
		[self setComputerName:[CPSystemInformation computerName]];
		[self setServiceUID:[_battery uniqueID]];

		[self probeBattery];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLStartMonitoringAtLaunchKey] boolValue])
		{
			[self startMonitoring];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_handleNotification:)
													 name:MBLProbeIntervalChangedNotification
												   object:nil];		
	
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(_handleSleepWakeShutdown:)
																   name:NSWorkspaceWillSleepNotification
																 object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(_handleSleepWakeShutdown:)
																   name:NSWorkspaceDidWakeNotification
																 object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
															   selector:@selector(_handleSleepWakeShutdown:)
																   name:NSWorkspaceWillPowerOffNotification
																 object:nil];		
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[self stopMonitoring];
	[_computerName release];
	
	[super dealloc];
}

- copyWithZone:(NSZone *)zone
{
    LocalBatteryManager *mgr = (LocalBatteryManager *)[super copyWithZone:zone];
    return mgr;
}

- (id)name
{
	NSString *theName = (_LocalBatteryManagerInstalledBatteries > 1) ?
		[NSString stringWithFormat:@"%@ (%d)", _computerName, (_index + 1)] : _computerName;
	return [NSArray arrayWithObjects:theName, _machineType, nil];
}

- (void)probeBattery
{
	//NSLog(@"-[%@ probeBattery]", [self class]);
	// Get current battery properties
	NSDictionary *props = [self _batteryProperties];
	
	// ...create an event...
	BatteryEvent *event = [BatteryEvent batteryEventWithDetails:props
														  index:_index
														   time:[NSCalendarDate calendarDate]];	
	// ...and consume it
	[self _consumeBatteryEvent:event];
}

- (void)startMonitoring
{
	if (_monitoring)
		return;
	
	SCDynamicStoreContext context = {0, self, NULL, NULL, NULL};
	
	// Create a dynamic store ref
	_dynamicStore = SCDynamicStoreCreate(NULL, (CFStringRef)@"BatteryManager", storeCallBack, &context);
	
	// What am I interested in receiving notifications
	// about?
	/*
	NSArray *keys = [NSArray arrayWithObjects:[NSString stringWithFormat:BATTERY_PATTERN, _index],
		nil];
	 */
	NSArray *patterns = [NSArray arrayWithObject:@"State:/IOKit/PowerSources/.*"];
	
	// Register for the notification
	if (!SCDynamicStoreSetNotificationKeys(_dynamicStore,
										   NULL, //(CFArrayRef)keys,
										   (CFArrayRef)patterns)) {
		NSLog(@"failed to set notification keys");
	}
	
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = 
		SCDynamicStoreCreateRunLoopSource(NULL, _dynamicStore, 0);
	
	// Get hold of the current run loop
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	
	// Add the source to the run loop
	CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
	
	// The source will be retained by the run loop
	CFRelease(runLoopSource);

	// If necessary, start a poll timer
	if ([_battery isPlugged])
	{
		[self _startPollTimer];
	}
	
	[self setMonitoring:YES];
}

- (void)stopMonitoring
{
	if (!_monitoring)
		return;
	
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = 
		SCDynamicStoreCreateRunLoopSource(NULL, _dynamicStore, 0);
	
	// Get hold of the current run loop
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	
	// Remove the source from the run loop
	CFRunLoopRemoveSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
	
	CFRelease(_dynamicStore);

	[self _stopPollTimer];
	
	[self setMonitoring:NO];
}

- (void)setComputerName:(NSString *)name
{
	[name retain];
	[_computerName release];
	_computerName = name;
}

- (NSString *)computerName
{
	return _computerName;
}

@end

@implementation LocalBatteryManager (Private)

- (NSDictionary *)_batteryProperties
{
	mach_port_t master_device_port;
	kern_return_t kr;
	CFArrayRef battery_info;
	NSDictionary *dict = nil;
	
	kr = IOMasterPort(bootstrap_port, &master_device_port);
	if (kr == kIOReturnSuccess)
	{
		if(kIOReturnSuccess != IOPMCopyBatteryInfo(master_device_port, &battery_info))
		{
			NSLog(@"Failed to obtain battery info. Are you sure that this computer has a battery?\n");
		}
		else
		{
			// Retain it to avoid deallocation...
			dict = [(NSDictionary *)CFArrayGetValueAtIndex(battery_info, _index) retain];
			// ...when we release its owner
			CFRelease(battery_info);
		}
	}
	
	// return autoreleased
	return [dict autorelease];
}

- (void)_consumeBatteryEvent:(BatteryEvent *)evt
{
	[super _consumeBatteryEvent:evt];
	
	//NSLog(@"[%@] Consuming BatteryEvent (%@)", [self class], evt);
	//NSLog(@"[%@] BatteryEvent details: (%@)", [self class], [evt details]);
	
	// Do we have to start the probe timer?
	if (([_battery isPlugged] && ![evt isPlugged]))
	{
		[self _stopPollTimer];
	}
	else if (![_battery isPlugged] && [evt isPlugged])
	{
		[self _startPollTimer];
	}
	
	[_battery setInstalled:[evt isInstalled]];
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

- (void)_handleCallback
{
	// Receive the notified key/value pairs
	NSDictionary *dict = (NSDictionary *)SCDynamicStoreCopyValue(_dynamicStore,
																 (CFStringRef)[NSString stringWithFormat:BATTERY_PATTERN, _index]);
	// Manually get other values by ourselves
	NSMutableDictionary *biggerDict = [[self _batteryProperties] mutableCopy];
	
	// Merge the two...
	[biggerDict addEntriesFromDictionary:dict];
	
	// ...create an event...
	BatteryEvent *event = [BatteryEvent batteryEventWithDetails:biggerDict
														  index:_index
														   time:[NSCalendarDate calendarDate]];
	
	// ...and consume it
	[self _consumeBatteryEvent:event];
	
	// Cleanup
	[biggerDict release];
	[dict release];	
}

- (void)_startPollTimer
{
	if ([_pollTimer isValid])
		return;
	
	int interval = [[[NSUserDefaults standardUserDefaults] objectForKey:MBLProbeIntervalKey] intValue];
	
	if (interval > 0)
	{
		_pollTimer = [[NSTimer scheduledTimerWithTimeInterval:interval
													   target:self
													 selector:@selector(probeBattery)
													 userInfo:NULL
													  repeats:YES] retain];
	}
}

- (void)_stopPollTimer
{
	if (![_pollTimer isValid])
		return;
	
	//NSLog(@"Stopping battery poll timer");
	[_pollTimer invalidate];
	_pollTimer = nil;
}

void storeCallBack( SCDynamicStoreRef    store,
					CFArrayRef changedKeys,
					void *info)
{
	LocalBatteryManager *manager = (LocalBatteryManager *)info;
	[manager _handleCallback];
}

- (void)_handleSleepWakeShutdown:(NSNotification *)note
{
	BatteryEvent *evt;
	if ([[note name] isEqual:NSWorkspaceDidWakeNotification])
	{
		evt = [[[WakeUpEvent alloc] init] autorelease];
	}
	else if ([[note name] isEqual:NSWorkspaceWillSleepNotification])
	{
		evt = [[[SleepEvent alloc] init] autorelease];
	}
	else if ([[note name] isEqual:NSWorkspaceWillPowerOffNotification])
	{
		// Do nothing
		return;
	}
	[(MonitoringSession *)[_sessions objectAtIndex:0] addEvent:evt];

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
		[self _stopPollTimer];
		[self _startPollTimer];
	}
}

- (void)_initBatteryProperties
{
	io_service_t smart_battery;
	
	// What service am I interested in?
	CFMutableDictionaryRef serviceName = IOServiceMatching( kMBLAppleSmartBatteryName );
	//NSLog(@"%@", serviceName);
	smart_battery = IOServiceGetMatchingService( kIOMasterPortDefault, 
												 serviceName );
	//NSLog(@"%d", smart_battery);
	if (smart_battery)
	{
		/* Now let's examine some more properties */
		CFTypeRef ret;
		
		/* Manufacturer */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSManufacturerKey),
											  kCFAllocatorDefault,
											  0);
		//CFShow(ret);
		[_battery setManufacturer:(NSString *)ret];
		
		if (ret)
			CFRelease(ret);
		
		/* Device Name */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMDeviceNameKey),
											  kCFAllocatorDefault,
											  0);
		//CFShow(ret);
		[_battery setDeviceName:(NSString *)ret];
		
		if (ret)
			CFRelease(ret);
		
		/* Serial */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSSerialKey),
											  kCFAllocatorDefault,
											  0);
		//CFShow(ret);
		[_battery setSerial:(NSString *)ret];
		
		if (ret)
			CFRelease(ret);
		
		/* Manufacture Date */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSManufactureDateKey),
											  kCFAllocatorDefault,
											  0);
		//CFShow(ret);
		int dateMask = [((NSNumber *)ret) intValue];		
		[_battery setManufactureDate:[NSCalendarDate dateWithBatteryManufactureDate:dateMask]];
		
		if (ret)
			CFRelease(ret);
		
		/* Design Capacity */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSDesignCapacityKey),
											  kCFAllocatorDefault,
											  0);
		//CFShow(ret);
		int designCapacity = [((NSNumber *)ret) intValue];
		[_battery setDesignCapacity:designCapacity];

		if (ret)
			CFRelease(ret);
	}
}

@end
