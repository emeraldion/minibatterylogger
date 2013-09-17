//
//  MiniBatteryStatusPlugin.m
//  MiniBatteryStatus
//
//  Created by delphine on 7-03-2006.
//  Copyright 2006 Emeraldion Lodge. All rights reserved.
//

#import "MiniBatteryStatusPlugin.h"
#import "CPSystemInformation.h"

static NSString *MBLGrowlChargeStartedNotification;
static NSString *MBLGrowlChargeStoppedNotification;
static NSString *MBLGrowlBatteryLowNotification;
static NSString *MBLGrowlPowerSourceChangedNotification;
static NSString *MBLGrowlBatteryChangedNotification;

@implementation MiniBatteryStatusPlugin

/*********************************************/
// Methods required by the WidgetPlugin protocol
/*********************************************/

// This method is called when the widget plugin is first loaded as the
// widget's web view is first initialized

+ (void)initialize
{
	/* Growl Notification Names */
	MBLGrowlChargeStartedNotification			= NSLocalizedString(@"Charge Started", @"Charge Started");
	MBLGrowlChargeStoppedNotification			= NSLocalizedString(@"Charge Stopped", @"Charge Stopped");
	MBLGrowlBatteryLowNotification				= NSLocalizedString(@"Battery Low", @"Battery Low");
	MBLGrowlPowerSourceChangedNotification		= NSLocalizedString(@"Power Source Changed", @"Power Source Changed");
	MBLGrowlBatteryChangedNotification			= NSLocalizedString(@"Battery Changed", @"Battery Changed");
}

- (id)initWithWebView:(WebView *)aWebView
{
	if (self = [super init])
	{
		[self setWebView:aWebView];
		// Create managers array
		batteryManagers = [[NSMutableArray alloc] init];
		
		int i;
		LocalBatteryManager *mgr;
		for (i = 0; i < [LocalBatteryManager installedBatteries]; i++)
		{
			mgr = [[LocalBatteryManager alloc] initWithIndex:i];
			// Disable logging; we don't need a history of events
			[mgr setLogging:NO];
			// Manually start monitoring, since there's no default key here
			[mgr startMonitoring];
			// Append to batteryManagers collection
			[batteryManagers addObject:mgr];
			
			if (!batteryManager)
			{
				batteryManager = mgr;
			}
			// Clean up
			[mgr release];
		}
		// Create a demo manager
		DemoBatteryManager *demoMgr = [[DemoBatteryManager alloc] init];
		// Disable logging
		[demoMgr setLogging:NO];
		// Append to batteryManagers collection
		[batteryManagers addObject:demoMgr];
		
		growlDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
			[NSArray arrayWithObjects:
				MBLGrowlChargeStoppedNotification,
				MBLGrowlBatteryLowNotification,
				MBLGrowlPowerSourceChangedNotification,
				nil],
			GROWL_NOTIFICATIONS_ALL,
			[NSArray arrayWithObjects:
				MBLGrowlChargeStoppedNotification,
				MBLGrowlBatteryLowNotification,
				MBLGrowlPowerSourceChangedNotification,
				nil],
			GROWL_NOTIFICATIONS_DEFAULT,
			nil];
		[GrowlApplicationBridge setGrowlDelegate:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(batteryPropertiesChanged:)
													 name:MBLBatteryPropertiesChangedNotification
												   object:nil];
		
		NSLog(@"MiniBatteryStatusPlugin initialized");
	}		
	return self;
}

- (void)dealloc
{
	[self setWebView:nil];
	[growlDictionary release];
	[batteryManagers release];
	[super dealloc];
}

- (void)setWebView:(WebView *)view
{
	[view retain];
	[webView release];
	webView = view;	
}

- (void)monitorBatteryAtIndex:(int)index
{
	//NSLog(@"monitorBatteryAtIndex:%d", index);
	//NSLog(@"locationInRange:%d", NSLocationInRange(index, NSMakeRange(0, [batteryManagers count])));
	if (NSLocationInRange(index, NSMakeRange(0, [batteryManagers count])))
	{
		batteryManager = [batteryManagers objectAtIndex:index];
		//NSLog(@"batteryManager:%@", batteryManager);
		if (index == [batteryManagers count] - 1)
		{
			// Manually start demo manager
			[batteryManager startMonitoring];
		}
		// Force redisplay
		[[webView windowScriptObject] evaluateWebScript:@"displayStatus()"];
	}
}

- (int)getBatteryCount
{
	return [LocalBatteryManager installedBatteries];
}

- (int)charge
{
	return [[batteryManager battery] charge];
}

- (int)capacity
{
	return [[batteryManager battery] capacity];
}

- (int)maxCapacity
{
	return [[batteryManager battery] maxCapacity];
}

- (int)designCapacity
{
	return [[batteryManager battery] designCapacity];
}

- (int)amperage
{
	return [[batteryManager battery] amperage];
}

- (int)voltage
{
	return [[batteryManager battery] voltage];
}

- (int)cycleCount
{
	return [[batteryManager battery] cycleCount];
}

- (BOOL)isInstalled
{
	return [[batteryManager battery] isInstalled];
}

- (BOOL)isPlugged
{
	return [[batteryManager battery] isPlugged];
}

- (BOOL)isCharging
{
	return [[batteryManager battery] isCharging];
}

- (NSTimeInterval)timeToEmpty
{
	return [[batteryManager battery] timeToEmpty];
}

- (NSTimeInterval)timeToFull
{
	return [[batteryManager battery] timeToFullCharge];
}

- (NSString *)machineType
{
	return [[CPSystemInformation machineType] substringFromIndex:1];
}

- (NSString *)serviceUID
{
	return [batteryManager serviceUID];
}

- (NSString *)deviceName
{
	return [[batteryManager battery] deviceName];
}

- (NSString *)manufacturer
{
	return [[batteryManager battery] manufacturer];
}

- (NSString *)manufactureDate
{
	return [[[batteryManager battery] manufactureDate] descriptionWithCalendarFormat:@"%Y-%m-%d"];
}

- (void)batteryPropertiesChanged:(NSNotification *)notif
{
	if ([[notif name] isEqualToString:MBLBatteryPropertiesChangedNotification])
	{
		if ([notif object] == batteryManager)
		{
			WebScriptObject *wso = [webView windowScriptObject];
			[wso evaluateWebScript:@"displayStatus()"];
		}		
	}
}

- (void)enterDemoMode
{
	
	[self performSelector:@selector(exitDemoMode)
			   withObject:nil
			   afterDelay:10];
}

- (void)exitDemoMode
{
	[batteryManager startMonitoring];
}

/*********************************************/
// Methods required by the WebScripting protocol
/*********************************************/

// This method gives you the object that you use to bridge between the
// Obj-C world and the JavaScript world.  Use setValue:forKey: to give
// the object the name it's refered to in the JavaScript side.
- (void)windowScriptObjectAvailable:(WebScriptObject*)wso
{
	//NSLog(@"windowScriptObjectAvailable:");
	[wso setValue:self forKey:@"Plugin"];
	//NSLog(@"Set myself as Plugin");
}

// This method lets you offer friendly names for methods that normally 
// get mangled when bridged into JavaScript.
+ (NSString *)webScriptNameForSelector:(SEL)aSel
{
	if (aSel == @selector(notifyBatteryLowWithTitle:details:))
	{
		return @"notifyBatteryLowWithTitleDetails";
	}
	else if (aSel == @selector(notifyBatteryFullWithTitle:details:))
	{
		return @"notifyBatteryFullWithTitleDetails";
	}
	else if (aSel == @selector(notifyPowerChangeWithTitle:details:))
	{
		return @"notifyPowerChangeWithTitleDetails";
	}
	else if (aSel == @selector(getBatteryCount))
	{
		return @"getBatteryCount";
	}
	else if (aSel == @selector(monitorBatteryAtIndex:))
	{
		return @"monitorBatteryAtIndex";
	}
	else if (aSel == @selector(charge))
	{
		return @"charge";
	}
	else if (aSel == @selector(capacity))
	{
		return @"capacity";
	}
	else if (aSel == @selector(maxCapacity))
	{
		return @"maxCapacity";
	}
	else if (aSel == @selector(designCapacity))
	{
		return @"designCapacity";
	}
	else if (aSel == @selector(amperage))
	{
		return @"amperage";
	}
	else if (aSel == @selector(voltage))
	{
		return @"voltage";
	}
	else if (aSel == @selector(cycleCount))
	{
		return @"cycleCount";
	}
	else if (aSel == @selector(isInstalled))
	{
		return @"isInstalled";
	}
	else if (aSel == @selector(isCharging))
	{
		return @"isCharging";
	}
	else if (aSel == @selector(isPlugged))
	{
		return @"isPlugged";
	}
	else if (aSel == @selector(timeToFull))
	{
		return @"timeToFull";
	}
	else if (aSel == @selector(timeToEmpty))
	{
		return @"timeToEmpty";
	}
	else if (aSel == @selector(machineType))
	{
		return @"machineType";
	}
	else if (aSel == @selector(serviceUID))
	{
		return @"serviceUID";
	}
	else if (aSel == @selector(manufacturer))
	{
		return @"manufacturer";
	}
	else if (aSel == @selector(manufactureDate))
	{
		return @"manufactureDate";
	}
	else if (aSel == @selector(deviceName))
	{
		return @"deviceName";
	}
	else
	{
		NSLog(@"Error: unknown selector");
		return nil;
	}
}

// This method lets you filter which methods in your plugin are accessible 
// to the JavaScript side.
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSel {  
	if (aSel == @selector(notifyBatteryLowWithTitle:details:) ||
		aSel == @selector(notifyBatteryFullWithTitle:details:) ||
		aSel == @selector(notifyPowerChangeWithTitle:details:) ||
		aSel == @selector(monitorBatteryAtIndex:) ||
		aSel == @selector(getBatteryCount) ||
		aSel == @selector(charge) ||
		aSel == @selector(capacity) ||
		aSel == @selector(maxCapacity) ||
		aSel == @selector(designCapacity) ||
		aSel == @selector(amperage) ||
		aSel == @selector(voltage) ||
		aSel == @selector(cycleCount) ||
		aSel == @selector(isInstalled) ||
		aSel == @selector(isPlugged) ||
		aSel == @selector(isCharging) ||
		aSel == @selector(timeToEmpty) ||
		aSel == @selector(timeToFull) ||
		aSel == @selector(machineType) ||
		aSel == @selector(deviceName) ||
		aSel == @selector(manufacturer) ||
		aSel == @selector(manufactureDate) ||
		aSel == @selector(serviceUID))
	{
		return NO;
	}
	return YES;
}

// Prevents direct key access from JavaScript.
+ (BOOL)isKeyExcludedFromWebScript:(const char*)key
{
	return YES;
}

/* Growl delegate methods */

- (NSDictionary *) registrationDictionaryForGrowl
{
	return growlDictionary;
}

- (NSString *) applicationNameForGrowl
{
	return [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:(NSString *)kCFBundleExecutableKey];
}

- (NSData *) applicationIconDataForGrowl
{
	return [[NSData alloc] initWithContentsOfFile:
		[[NSBundle bundleForClass:[self class]] pathForResource:@"MiniBatteryStatus" ofType:@"icns"]];
}

/* MiniBatteryStatus widget bridge methods */

- (void)notifyBatteryLowWithTitle:(NSString *)title details:(NSString *)details
{
	[GrowlApplicationBridge notifyWithTitle:title
								description:details
						   notificationName:MBLGrowlBatteryLowNotification
								   iconData:[self applicationIconDataForGrowl]
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (void)notifyBatteryFullWithTitle:(NSString *)title details:(NSString *)details
{
	
	[GrowlApplicationBridge notifyWithTitle:title
								description:details
						   notificationName:MBLGrowlChargeStoppedNotification
								   iconData:[self applicationIconDataForGrowl]
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (void)notifyPowerChangeWithTitle:(NSString *)title details:(NSString *)details
{
	
	[GrowlApplicationBridge notifyWithTitle:title
								description:details
						   notificationName:MBLGrowlPowerSourceChangedNotification
								   iconData:[self applicationIconDataForGrowl]
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

@end
