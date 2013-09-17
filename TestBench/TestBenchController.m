//
//  TestBenchController.m
//  MiniBatteryLogger
//
//  Created by delphine on 25-01-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import "TestBenchController.h"
#import <IOKit/pwr_mgt/IOPM.h>

#define kMBLPPCServiceName "IOHWSensor"
#define kMBLPPCPropertyName "location"

#define kMBLAppleSmartBatteryManagerName "AppleSmartBatteryManager"
#define kMBLAppleSmartBatteryName "AppleSmartBattery"
//#define kMBLAppleSmartBatteryName "IOPMrootDomain"

//#define kMBLDesignCapacityKey "DesignCapacity"
//#define kMBLManufactureDateKey "ManufactureDate"

@class RemoteBatteryManager;

@implementation TestBenchController

- (IBAction)startTestSuite:(id)sender
{
	NSTimeInterval delay = 0.0;	
	[self performMacIntelTest:sender];
	[self startInfoTest:sender];
	delay += 1.0;
	[self performSelector:@selector(performCopyBatteryInfoTest:)
			   withObject:sender
			   afterDelay:delay];
	delay += 1.0;
	[self performSelector:@selector(performIOPSCopyPowerSourcesInfoTest:)
			   withObject:sender
			   afterDelay:delay];	
	delay += 1.0;
	[self performSelector:@selector(startIOPSNotificationCreateRunLoopSourceTest:)
			   withObject:sender
			   afterDelay:delay];
	delay += 60.0;
	[self performSelector:@selector(stopInfoTest:)
			   withObject:nil
			   afterDelay:delay];	
	delay += 1.0;
	[self performSelector:@selector(stopIOPSNotificationCreateRunLoopSourceTest:)
			   withObject:sender
			   afterDelay:delay];
	delay += 1.0;
	[self performSelector:@selector(sendResultsByMail:)
			   withObject:sender
			   afterDelay:delay];
}

- (IBAction)startInfoTest:(id)sender
{
	if (test1Running)
		return;

	SCDynamicStoreContext context = {0, self, NULL, NULL, NULL};
	
	// Create a dynamic store ref
	dynamicStore = SCDynamicStoreCreate(NULL, (CFStringRef)@"MBL-TestBench", _storeCallBack, &context);
	
	// What am I interested in receiving notifications
	// about?
	NSArray *keys = [NSArray arrayWithObjects:@"State:/IOKit/PowerSources/InternalBattery-0",
		@"State:/IOKit/PowerSources/InternalBattery-1",
		nil];
	NSArray *patterns = [NSArray arrayWithObject:@"State:/IOKit/PowerSources/.*"];
	
	// Register for the notification
	if (!SCDynamicStoreSetNotificationKeys(dynamicStore,
										   NULL, //(CFArrayRef)keys,
										   (CFArrayRef)patterns)) {
		NSLog(@"failed to set notification keys");
	}
	
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = 
		SCDynamicStoreCreateRunLoopSource(NULL,dynamicStore,0);
	
	// Get hold of the current run loop
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	
	// Add the source to the run loop
	CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
	
	// The source will be retained by the run loop
	CFRelease(runLoopSource);

	[infoProgress startAnimation:sender];
	test1Running = YES;
}

- (IBAction)stopInfoTest:(id)sender
{
	if (!test1Running)
		return;
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = 
	SCDynamicStoreCreateRunLoopSource(NULL,dynamicStore,0);

	// Get hold of the current run loop
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	
	// Remove the source from the run loop
	CFRunLoopRemoveSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
	
	CFRelease(dynamicStore);
	
	[infoProgress stopAnimation:sender];
	test1Running = NO;
}

- (IBAction)performCopyBatteryInfoTest:(id)sender
{
	mach_port_t master_device_port;
	kern_return_t kr;
	CFArrayRef battery_info;
	int count = 0;
	
	kr = IOMasterPort(bootstrap_port,&master_device_port);
	if ( kr == kIOReturnSuccess )
	{
		if(kIOReturnSuccess != IOPMCopyBatteryInfo(master_device_port, &battery_info))
		{
			NSLog(@"Failed to obtain battery info. Are you sure that this computer has a battery?\n");
		}
		else
		{
			[self appendOutput:battery_info description:@"Call to IOPMCopyBatteryInfo"];
			CFRelease(battery_info);
		}
	}
}

- (IBAction)performIOPSCopyPowerSourcesInfoTest:(id)sender
{
	CFTypeRef ret = IOPSCopyPowerSourcesInfo();
	if (ret)
	{
		CFArrayRef arr = IOPSCopyPowerSourcesList(ret);
		if (arr)
		{
			CFIndex i, count;
			count = CFArrayGetCount(arr);
			for (i = 0; i < count; i++)
			{
				CFDictionaryRef dict = IOPSGetPowerSourceDescription(ret, CFArrayGetValueAtIndex(arr,i));
				[self appendOutput:dict description:@"IOPSCopyPowerSourcesInfo output"];
			}
		}
		CFRelease(arr);
	}
	CFRelease(ret);
}

- (IBAction)startIOPSNotificationCreateRunLoopSourceTest:(id)sender
{
	runLoopSource = IOPSNotificationCreateRunLoopSource(powerSourceCallback,				   
														self);
	if (runLoopSource)
	{
		CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource,
						   kCFRunLoopDefaultMode);
	}
	else
	{
		NSLog(@"IOPSNotificationCreateRunLoopSource returned NULL");
	}
}

- (IBAction)stopIOPSNotificationCreateRunLoopSourceTest:(id)sender
{
	if (runLoopSource)
	{
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource,
							  kCFRunLoopDefaultMode);
		CFRelease(runLoopSource);
	}
	else
	{
		NSLog(@"Nothing to do here");
	}
}


- (IBAction)sendResultsByMail:(id)sender
{
	NSMutableString *message = [[infoOutput textStorage] string];
	
	[message appendString:@"\n"];
	
	[message appendString:[[intelOutput textStorage] string]];

	NSURL *emailURL = [NSURL URLWithString:[@"mailto:emeraldion@emeraldion.it?subject=MBL%20TestBench%20Results&body=" stringByAppendingString:[message stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
	[[NSWorkspace sharedWorkspace] openURL:emailURL];
}

- (void)appendOutput:(id)value description:(NSString *)desc
{		
	[self appendOutput:value
		   description:desc
			 textField:infoOutput];
}

- (void)appendOutput:(id)value description:(NSString *)desc textField:(id)field
{		
	NSAttributedString *attrStr;
	attrStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n=======================\n%@\n", desc, value]];
	[[field textStorage] appendAttributedString:attrStr];
	[attrStr release];
}

- (IBAction)performMacPPCTest:(id)sender
{
	io_service_t ppc_data;
	
	// What service am I interested in?
	CFMutableDictionaryRef serviceName = IOServiceMatching( kMBLPPCServiceName );
	//NSLog(@"%@", serviceName);
	ppc_data = IOServiceGetMatchingService( kIOMasterPortDefault, 
												 serviceName );
	//NSLog(@"%d", smart_battery);
	if (ppc_data)
	{
		io_name_t devName;
		io_string_t pathName;
		NSMutableString *resultStr;
		
		/* Now let's examine some more properties */
		CFTypeRef ret;
		
		/* Manufacturer */
		ret = IORegistryEntryCreateCFProperty(ppc_data, 
											  CFSTR(kMBLPPCPropertyName),
											  kCFAllocatorDefault,
											  0);
		CFShow(ret);
		resultStr = [NSString stringWithFormat:@"%@: %@\n", CFSTR(kMBLPPCPropertyName), ret];
		
		CFRelease(ret);
		
		[self appendOutput:resultStr
			   description:@"PPC details"
				 textField:ppcOutput];
	}
	else
	{
		[self appendOutput:@"No device matching. Are you on an Intel Mac??"
			   description:@"PPC test failed"
				 textField:ppcOutput];
	}	
}

- (IBAction)performMacIntelTest:(id)sender
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
		io_name_t devName;
		io_string_t pathName;
		NSMutableString *resultStr;
		
		/* Get some easy properties */
		IORegistryEntryGetName(smart_battery, devName);		
		resultStr = [NSMutableString stringWithFormat:@"Device's name = %s\n", devName];

		IORegistryEntryGetPath(smart_battery, kIOServicePlane, pathName);
		[resultStr appendFormat:@"Device's path in IOService plane = %s\n", pathName];
		
		/* Now let's examine some more properties */
		CFTypeRef ret;
		
		/* Manufacturer */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSManufacturerKey),
											  kCFAllocatorDefault,
											  0);
		if (ret)
			CFShow(ret);
		[resultStr appendFormat:@"Manufacturer: %@\n", ret];
		
		if (ret)
			CFRelease(ret);

		/* Device Name */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMDeviceNameKey),
											  kCFAllocatorDefault,
											  0);
		if (ret)
			CFShow(ret);
		[resultStr appendFormat:@"Device Name: %@\n", ret];
		
		if (ret)
			CFRelease(ret);

		/* Serial */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSSerialKey),
											  kCFAllocatorDefault,
											  0);
		if (ret)
			CFShow(ret);
		[resultStr appendFormat:@"Serial: %@\n", ret];
		
		if (ret)
			CFRelease(ret);
		
		/* Manufacture Date */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSManufactureDateKey),
											  kCFAllocatorDefault,
											  0);
		if (ret)
			CFShow(ret);
		int dateMask = [((NSNumber *)ret) intValue];
		NSString *manufactureDate = [[NSCalendarDate dateWithBatteryManufactureDate:dateMask] descriptionWithCalendarFormat:@"%e %B %Y"];

		[resultStr appendFormat:@"Manufacture Date: %d (%@)\n", dateMask, manufactureDate];
		
		if (ret)
			CFRelease(ret);
		
		/* Design Capacity */
		ret = IORegistryEntryCreateCFProperty(smart_battery, 
											  CFSTR(kIOPMPSDesignCapacityKey),
											  kCFAllocatorDefault,
											  0);
		if (ret)
			CFShow(ret);
		int designCapacity = [((NSNumber *)ret) intValue];
		[resultStr appendFormat:@"Design Capacity: %d\n", designCapacity];
		
		if (ret)
			CFRelease(ret);
				
		[self appendOutput:resultStr
			   description:@"AppleSmartBattery details"
				 textField:intelOutput];
	}
	else
	{
		[self appendOutput:@"No device matching. Are you on a PPC Mac??"
			   description:@"AppleSmartBattery test failed"
				 textField:intelOutput];
	}
}

void powerSourceCallback(void *context)
{
	NSLog(@"powerSourceCallback");
	[context appendOutput:@"..." description:@"IOPSNotificationCreateRunLoopSource called powerSourceCallback"];
}

void _storeCallBack( SCDynamicStoreRef    store,
					CFArrayRef changedKeys,
					void *info)
{
	CFIndex count = CFArrayGetCount(changedKeys);
	CFIndex i;
	for (i = 0; i < count; ++i)
	{
		CFStringRef key = CFArrayGetValueAtIndex(changedKeys, i);
		CFDictionaryRef newValue = SCDynamicStoreCopyValue(store, key);
		if (newValue)
			[info appendOutput:newValue description:[NSString stringWithFormat:@"SCDynamicStore Notification for %@", key]];
	}
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

// We broadcast the willChangeValueForKey: and didChangeValueForKey: for the NSTableView binding to work.

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	NSLog(@"Found Net Service: %@", aNetService);
	batteryManager = [[RemoteBatteryManager alloc] initWithService:aNetService index:0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
}

- (void)batteryPropertiesChanged:(NSNotification *)notif
{
	NSLog(@"notif:%@", notif);
	NSLog(@"[notif object]:%@", [notif object]);	
	NSLog(@"[[notif object] battery]:%@", [[notif object] battery]);	
}

@end

@implementation TestBenchController (NSApplicationDelegate)

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

@end

@implementation TestBenchController (NSNibAwaking)

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryPropertiesChanged:)
												 name:MBLBatteryPropertiesChangedNotification
											   object:nil];
	
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
	[serviceBrowser searchForServicesOfType:@"_mbl-battd._tcp." inDomain:@""];
/*
	RemoteBatteryManager *remote = [[RemoteBatteryManager alloc] initWithRemoteAddress:[NSData data]
																				 index:0];
*/
}

@end
