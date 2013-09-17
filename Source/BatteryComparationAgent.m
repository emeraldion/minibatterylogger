//
//  BatteryComparationAgent.m
//  MiniBatteryLogger
//
//  Created by delphine on 24-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "BatteryComparationAgent.h"
#import "DifferentialBattery.h"

#define YEAR_TIME_INTERVAL (3600 * 24 * 365)
#define MONTH_TIME_INTERVAL (3600 * 24 * 30)
// This value shall be set in the Notifications preferences.
#define WARNING_TIME_INTERVAL (3600 * 24 * 30)

typedef enum
{
	BatteryComparationAgentSendDataMode = 1,
	BatteryComparationAgentFetchDataMode
} BatteryComparationAgentOperatingModes;

static NSString *BatteryComparationAgentSharedSecret = @"adelia";

/*
 static NSString *BatteryComparationAgentFetchURL = @"http://192.168.1.5:1080/mbl/fetch/";
 static NSString *BatteryComparationAgentShareURL = @"http://192.168.1.5:1080/mbl/send/";
 static NSString *BatteryComparationAgentSharedArchiveURL = @"http://192.168.1.5:1080/mbl/";
 */

static NSString *BatteryComparationAgentFetchURL = @"http://burgos.emeraldion.it/mbl/fetch/";
static NSString *BatteryComparationAgentShareURL = @"http://burgos.emeraldion.it/mbl/send/";
static NSString *BatteryComparationAgentSharedArchiveURL = @"http://burgos.emeraldion.it/mbl/";

static NSString *BCAPartKey = @"part";
static NSString *BCASupportedKey = @"supported";

NSString *MBLHumanMachineModelKey = @"Human Machine Model";
NSString *MBLBatteryPurchaseDateKey = @"Battery Purchase Date";
NSString *MBLArchiveAPIVersion = @"1.1";

extern NSString *MBLRetrieveDataKey;

@class BatteryManager, ELPillTextFieldCell;

@interface BatteryComparationAgent (Private)

- (void)batteryManagerChanged:(NSNotification *)notif;
- (void)registerUserValues;
- (BOOL)scanReferenceBatteries:(NSString *)response;
- (NSString *)overallRatingForMark:(float)mark;
- (void)_updateStatsForManager:(BatteryManager *)mgr;

@end

@implementation BatteryComparationAgent

- (void)dealloc
{
	[CURLHandle curlGoodbye];	// to clean up
	[mURLHandle release];
	[machineType release];
	[machineModel release];
	[computerName release];
	[computerSerialNumber release];
	[super dealloc];
}

- (void)setBatteryPartNumbers:(NSDictionary *)dict
{
	[dict retain];
	[batteryPartNumbers release];
	batteryPartNumbers = dict;
}

- (void)setBatteryModel:(NSString *)model
{
	[model retain];
	[batteryModel release];
	batteryModel = model;
}

- (void)setMachineType:(NSString *)type
{
	[type retain];
	[machineType release];
	machineType = type;
}

- (void)setMachineModel:(NSString *)model
{
	[model retain];
	[machineModel release];
	machineModel = model;
}

- (void)setComputerName:(NSString *)name
{
	[name retain];
	[computerName release];
	computerName = name;
}

- (void)setComputerSerialNumber:(NSString *)num
{
	[num retain];
	[computerSerialNumber release];
	computerSerialNumber = num;
}

- (void)setBatteryDate:(NSCalendarDate *)date
{
	[date retain];
	[batteryDate release];
	batteryDate = date;
}

- (void)setURLHandle:(CURLHandle *)handle
{
	[handle retain];
	[mURLHandle release];
	mURLHandle = handle;
}

- (void)setOwnModelCount:(int)count
{
	if (count > 0)
	{
		ownModelCount = count;
	}
}
- (void)setOwnMachineCount:(int)count
{
	if (count > 0)
	{
		ownMachineCount = count;
	}
}

- (void)setAllCount:(int)count
{
	if (count > 0)
	{
		allCount = count;
	}
}

- (int)ownMachineCount
{
	return ownMachineCount;
}
- (int)ownModelCount
{
	return ownModelCount;
}

- (int)allCount
{
	return allCount;
}

- (IBAction)chooseExactMachineType:(id)sender
{
	[self setMachineModel:[sender titleOfSelectedItem]];
	[[NSUserDefaults standardUserDefaults] setObject:machineModel
											  forKey:MBLHumanMachineModelKey];
	[self getSharedBatteryData:sender];
}

- (IBAction)updateBatteryDate:(id)sender
{
	NSCalendarDate *date = [NSCalendarDate dateWithString:[sender stringValue]
										   calendarFormat:@"%m/%Y"];
	[self setBatteryDate:date];
	[[NSUserDefaults standardUserDefaults] setObject:date
											  forKey:MBLBatteryPurchaseDateKey];
}

- (IBAction)shareBatteryData:(id)sender
{
	// If there's a load already in progress, cancel it
	if ([mURLHandle status] == NSURLHandleLoadInProgress)
	{
		[mURLHandle cancelLoadInBackground];
	}
	
	mOperationMode = BatteryComparationAgentSendDataMode;
	
	Battery *battery = (Battery *)[batteryController content];
	BatteryManager *mgr = [[managerController selectedObjects] objectAtIndex:0];
	
	//NSLog(@"Sending own battery data to Shared Battery Data Archive:\n%@", battery);
	
	NSURL *url;
	NSString *urlString = BatteryComparationAgentShareURL;
	
	NSDictionary *oPostDictionary;
	
	oPostDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
		[mgr serviceUID], @"hash",
		MBLArchiveAPIVersion, @"api_version",
		[NSNumber numberWithInt:[battery voltage]], @"voltage",
		[NSNumber numberWithInt:[battery cycleCount]], @"cycle_count",
		[NSNumber numberWithInt:[battery maxCapacity]], @"max_capacity",
		[NSNumber numberWithInt:[battery designCapacity]], @"design_capacity",
		[NSNumber numberWithBool:[appController isRegistered]], @"registered",
		([battery manufactureDate] ? [[battery manufactureDate] descriptionWithCalendarFormat:@"%Y-%m-%d"] : (batteryDate ? [batteryDate descriptionWithCalendarFormat:@"%Y-%m-01"] : @"2012-04-23")), @"manufacture_date",
		([battery manufacturer] ? [battery manufacturer] : @""), @"manufacturer",
		([battery deviceName] ? [battery deviceName] : @""), @"device_name",
		machineModel, @"model",
		[mgr machineType], @"machine",
		[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey], @"version",
		BatteryComparationAgentSharedSecret, @"key",
		nil];
	
	//NSLog(@"%@", oPostDictionary);
	
	// Add "http://" if missing
	if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"] && ![urlString hasPrefix:@"ftp://"])
	{
		urlString = [NSString stringWithFormat:@"http://%@",urlString];
	}
	
	urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	url = [NSURL URLWithString:urlString];
	
	if (nil != url)	// ignore if no URL
	{
		// set some options based on user input
		[self setURLHandle:(CURLHandle *)[url URLHandleUsingCache:NO]];
		
		[mURLHandle setFailsOnError:NO];		// don't fail on >= 300 code; I want to see real results.
		[mURLHandle setUserAgent:
			@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US)"];
		
		if (oPostDictionary != nil)
		{
			[mURLHandle setPostDictionary:oPostDictionary];
		}
		
		[mURLHandle setProgressIndicator:progress];
		
		mBytesRetrievedSoFar = 0;
		[mURLHandle addClient:self];
		
		// launch in background
		[mURLHandle loadInBackground];
	}	
}

- (IBAction)getSharedBatteryData:(id)sender
{
	// If there's a load already in progress, cancel it
	if ([mURLHandle status] == NSURLHandleLoadInProgress)
	{
		[mURLHandle cancelLoadInBackground];
	}
	
	mOperationMode = BatteryComparationAgentFetchDataMode;
	
	//NSLog(@"Fetching data from the Shared Battery Data Archive");
	
	NSURL *url;
	NSString *urlString = BatteryComparationAgentFetchURL;

	BatteryManager *mgr = [[managerController selectedObjects] objectAtIndex:0];

	NSDictionary *oPostDictionary;
	oPostDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
		[mgr machineType], @"machine",
		machineModel, @"model",
		BatteryComparationAgentSharedSecret, @"key",
		nil];
	
	// Add "http://" if missing
	if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"] && ![urlString hasPrefix:@"ftp://"])
	{
		urlString = [NSString stringWithFormat:@"http://%@",urlString];
	}
	
	urlString =  [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	url = [NSURL URLWithString:urlString];
	
	if (nil != url)	// ignore if no URL
	{
		// set some options based on user input
		[self setURLHandle:(CURLHandle *)[url URLHandleUsingCache:NO]];
		
		[mURLHandle setFailsOnError:NO];		// don't fail on >= 300 code; I want to see real results.
		[mURLHandle setUserAgent:
			@"Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US)"];
		
		if (oPostDictionary != nil)
		{
			[mURLHandle setPostDictionary:oPostDictionary];
		}
		
		[mURLHandle setProgressIndicator:progress];
		
		mBytesRetrievedSoFar = 0;
		[mURLHandle addClient:self];
		
		// launch in background
		[mURLHandle loadInBackground];
	}	
}

- (IBAction)gotoSharedBatteryDataArchive:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:BatteryComparationAgentSharedArchiveURL]];
}

- (IBAction)prepareDiagnostics:(id)sender
{
	Battery *battery = (Battery *)[batteryController content];
	
	// Calculate and show battery life details
	NSCalendarDate *deathDate = [wearView deathOfBattery];
	if (deathDate)
	{
		[batteryDeathLabel setStringValue:[deathDate descriptionWithCalendarFormat:NSLocalizedString(@"%m/%d/%Y", @"%m/%d/%Y")]];
		NSTimeInterval remainingLife = [deathDate timeIntervalSinceNow];
		
		int years, months;
		years = (int)(remainingLife / YEAR_TIME_INTERVAL);
		months = (int)(((((int)remainingLife) % YEAR_TIME_INTERVAL) * 1.0) / MONTH_TIME_INTERVAL);
		
		[remainingLifeLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d year(s), %d month(s)", @"%d year(s), %d month(s)"),
			years,
			months]];
		if (remainingLife < WARNING_TIME_INTERVAL)
		{
			[remainingLifeLabel setTextColor:[NSColor colorWithDeviceRed:192/255.0
																   green:0.0
																	blue:0.0																
																   alpha:1.0]];
		}
	}
	else
	{
		[batteryDeathLabel setStringValue:NSLocalizedString(@"Not available", @"Not available")];
		[remainingLifeLabel setStringValue:NSLocalizedString(@"Not available", @"Not available")];
	}
	
	float overallMark, ageMark, cyclesMark, capacityMark;
	/* Calculating age mark */
	NSTimeInterval age = fabs([batteryDate timeIntervalSinceNow]);
	ageMark = MAX(0, 5 * (1 - (age / (3600 * 24 * 365 * 5))));
	
	/* Calculating cycles mark */
	int cycleCount = [battery cycleCount];
	cyclesMark = MAX(0, 5  * (1 - (cycleCount / 800.0)));
	
	/* Calculating capacity mark */
	capacityMark = MAX(0, (5.0  * [battery maxCapacity] / [battery absoluteMaxCapacity]));
	
	/* Calculating overall mark */
	/* it is a weighted arithmetic mean */
	overallMark = (ageMark + cyclesMark + 3 * capacityMark) / 5;
	
	// Show marks as stars
	[overallSView setFloatValue:overallMark];
	[ageSView setFloatValue:ageMark];
	[cycleSView setFloatValue:cyclesMark];
	[capacitySView setFloatValue:capacityMark];
	
	// Add some descriptions
	[overallLabel setStringValue:[self overallRatingForMark:overallMark]];
	[ageLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d months", @"%d months"), (int)round(age / (3600 * 24 * 30))]];
	[cyclesLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d cycles", @"%d cycles"), cycleCount]];
	[capacityLabel setStringValue:[NSString stringWithFormat:@"%d/%d (%d%%)",
		[battery maxCapacity],
		[battery absoluteMaxCapacity],
		(int)round(100.0 * [battery maxCapacity] / [battery absoluteMaxCapacity])]];
	
	NSString *remarks = @"-";
	
	[remarksField setStringValue:remarks];
	
	NSImage *batteryImage;
	BOOL isBatterySupported;
	// Show battery details
	if (![batteryPartNumbers objectForKey:machineType])
	{
		// Unsupported model
		[self setBatteryModel:NSLocalizedString(@"Unknown", @"Unknown")];
		isBatterySupported = NO;
		batteryImage = [NSImage imageNamed:@"unknown-battery"];
	}
	else
	{
		if ([[batteryPartNumbers objectForKey:machineType] objectForKey:BCAPartKey])
		{
			[self setBatteryModel:[[batteryPartNumbers objectForKey:machineType] objectForKey:BCAPartKey]];
			isBatterySupported = [[[batteryPartNumbers objectForKey:machineType] objectForKey:BCASupportedKey] boolValue];
		}
		else
		{
			[self setBatteryModel:[[[batteryPartNumbers objectForKey:machineType] objectForKey:machineModel] objectForKey:BCAPartKey]];
			isBatterySupported = [[[[batteryPartNumbers objectForKey:machineType] objectForKey:machineModel] objectForKey:BCASupportedKey] boolValue];
		}
		batteryImage = [NSImage imageNamed:batteryModel];
	}
	[batteryIcon setImage:batteryImage];
}


- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{
	if (nil != progress)
	{
		id contentLength = [sender propertyForKeyIfAvailable:@"content-length"];
		
		mBytesRetrievedSoFar += [newBytes length];
		
		if (nil != contentLength)
		{
			double total = [contentLength doubleValue];
			[progress setIndeterminate:NO];
			[progress setMaxValue:total];
			[progress setDoubleValue:mBytesRetrievedSoFar];
		}
	}
	
}
- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{
	[progress startAnimation:self];
}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	NSData *data = [sender resourceData];	// if foreground, this will block 'til loaded.
	NSString *contentType = [sender propertyForKeyIfAvailable:@"content-type"];
	
	if (nil != progress)
	{
		[progress stopAnimation:self];
		[progress setIndeterminate:YES];
	}
	
	[sender removeClient:self];	// disconnect this from the URL handle	
	
	if (nil != data)	// it might be nil if failed in the foreground thread, for instance
	{
		NSString *bodyString = nil;
		
		if ([contentType hasPrefix:@"text/"])
		{
			bodyString = [[[NSString alloc] initWithData:data
												encoding:NSASCIIStringEncoding] autorelease];
		}
		else
		{
			bodyString = [NSString stringWithFormat:@"There were %d bytes of type %@",
				[data length], contentType];
		}
		
		//NSLog(@"%@", bodyString);
		
		switch (mOperationMode)
		{
			case BatteryComparationAgentFetchDataMode:
				if (![self scanReferenceBatteries:bodyString])
				{
					NSLog(@"Malformed response from server");
				}
				break;
		}
	}
}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
	if (nil != progress)
	{
		[progress stopAnimation:nil];
		[progress setIndeterminate:YES];
	}	
}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
	if (nil != progress)
	{
		[progress stopAnimation:nil];
		[progress setIndeterminate:YES];
	}
}

@end

@implementation BatteryComparationAgent (Private)

- (void)batteryManagerChanged:(NSNotification *)notif
{
	//NSLog(@"[%@ batteryManagerChanged:]: %@", [self class], [notif object]);
	if ([notif object] == managersList)
	{
		BatteryManager *mgr = [[managerController selectedObjects] objectAtIndex:0];
		
		[self _updateStatsForManager:mgr];
	}
}

- (void)_updateStatsForManager:(BatteryManager *)mgr
{
	[self setMachineType:[mgr machineType]];
	[self setComputerName:[[mgr name] objectAtIndex:0]];	
	
	// Empty the popupbutton
	[machineChooser removeAllItems];
	id humanMachineType = [CPSystemInformation humanMachineTypeForMachine:[mgr machineType]];

	if ([humanMachineType isKindOfClass:[NSArray class]])
	{
		// Populate the popupbutton menu with possible machine models
		[machineChooser addItemsWithTitles:humanMachineType];
		id model = [[NSUserDefaults standardUserDefaults] objectForKey:MBLHumanMachineModelKey];
		if (model)
		{
			[self setMachineModel:model];
			[machineChooser selectItemWithTitle:model];
		}
		else
		{
			[self setMachineModel:[humanMachineType objectAtIndex:0]];
		}
	}
	else
	{
		[machineChooser addItemsWithTitles:[NSArray arrayWithObject:humanMachineType]];
		[self setMachineModel:humanMachineType];
	}
	
	if ([CPSystemInformation isPowerPC])
	{
		id date = [[NSUserDefaults standardUserDefaults] objectForKey:MBLBatteryPurchaseDateKey];
		if (date)
		{
			NSCalendarDate *cal = [date dateWithCalendarFormat:nil
													  timeZone:nil];
			[batteryManufactureDateLabel setStringValue:[cal descriptionWithCalendarFormat:NSLocalizedString(@"%m/%d/%Y", @"%m/%d/%Y")]];
			[self setBatteryDate:cal];
			[batteryManufacturedLabel setStringValue:NSLocalizedString(@"Battery purchased:", @"Battery purchased:")];
		}
	}
	else
	{
		[self setBatteryDate:[[mgr battery] manufactureDate]];
		[batteryManufactureDateLabel setStringValue:[[[mgr battery] manufactureDate] descriptionWithCalendarFormat:NSLocalizedString(@"%m/%d/%Y", @"%m/%d/%Y")]];
		[batteryManufacturedLabel setStringValue:NSLocalizedString(@"Battery manufactured:", @"Battery manufactured:")];
	}

	if (computerName)
	{
		[hostNameLabel setStringValue:computerName];
		[hostNameBox setTitle:computerName];
	}
	else
	{
		[hostNameLabel setStringValue:NSLocalizedString(@"This Mac", @"This Mac")];
		[hostNameBox setTitle:NSLocalizedString(@"This Mac", @"This Mac")];
	}

	// Get shared battery data
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLRetrieveDataKey] boolValue])
	{
		[self getSharedBatteryData:nil];
	}
	
}

- (NSString *)overallRatingForMark:(float)mark
{
	if (mark >= 4.5)
	{
		return NSLocalizedStringFromTable(@"Excellent", @"Ratings", @"Excellent");
	}
	else if (mark >= 4.0)
	{
		return NSLocalizedStringFromTable(@"Very good", @"Ratings", @"Very good");
	}
	else if (mark >= 3.5)
	{
		return NSLocalizedStringFromTable(@"Good", @"Ratings", @"Good");
	}
	else if (mark >= 3.0)
	{
		return NSLocalizedStringFromTable(@"Above average", @"Ratings", @"Above average");
	}
	else if (mark >= 2.5)
	{
		return NSLocalizedStringFromTable(@"Average", @"Ratings", @"Average");
	}
	else if (mark >= 2.5)
	{
		return NSLocalizedStringFromTable(@"Below average", @"Ratings", @"Below average");
	}
	else if (mark >= 1.5)
	{
		return NSLocalizedStringFromTable(@"Poor", @"Ratings", @"Poor");
	}
	else
	{
		return NSLocalizedStringFromTable(@"Awful", @"Ratings", @"Awful");
	}
}

- (void)registerUserValues
{
}

- (BOOL)scanReferenceBatteries:(NSString *)response
{
    NSScanner *theScanner;	
	NSArray *batteryControllers;
    int voltage;
    int cycleCount;
    int maxCapacity;
    int designCapacity;
	
    theScanner = [NSScanner scannerWithString:response];
	batteryControllers = [NSArray arrayWithObjects:bestBatteryController,
		averageBatteryController,
		worstBatteryController,
		nil];
	
	int index = 0;
    //while ([theScanner isAtEnd] == NO) {
	while (index < [batteryControllers count]) {
        if ([theScanner scanInt:&voltage] &&
            [theScanner scanString:@":" intoString:NULL] &&
			[theScanner scanInt:&cycleCount] &&
            [theScanner scanString:@":" intoString:NULL] &&
			[theScanner scanInt:&maxCapacity] &&
            [theScanner scanString:@":" intoString:NULL] &&
			[theScanner scanInt:&designCapacity]) {
			
			Battery *batt = [[Battery alloc] init];
			[batt setCycleCount:cycleCount];
			[batt setVoltage:voltage];
			[batt setMaxCapacity:maxCapacity];
			[batt setDesignCapacity:designCapacity];
			[[batteryControllers objectAtIndex:index] setContent:batt];
			index++;
        }
        else return NO;
    }
	
	// Get count of own model and machine
	if ([theScanner scanInt:&allCount] &&
		[theScanner scanString:@":" intoString:NULL] &&
		[theScanner scanInt:&ownMachineCount] &&
		[theScanner scanString:@":" intoString:NULL] &&
		[theScanner scanInt:&ownModelCount])
	{
		[ownMachineCountLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d entries", @"%d entries"), ownMachineCount]];
		[ownModelCountLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%d entries", @"%d entries"), ownModelCount]];
	}
	
	// Create differential battery and add to differentialController
	// This virtual battery will be used to mark own stats as good (green)
	// or bad (red) compared to average
	
	Battery *averageBattery, *ownBattery;
	averageBattery = [averageBatteryController content];
	ownBattery = [batteryController content];

	[differentialBatteryController setContent:[ownBattery differentialBattery:averageBattery]];
	
    return YES;
} 

@end

@implementation BatteryComparationAgent (NSNibAwaking)

- (void)awakeFromNib
{
	// Register CURLHandle for handling URLs
	[CURLHandle curlHelloSignature:@"XxXx" acceptAll:YES];
	
	[self setBatteryPartNumbers:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"battery_part_numbers"
																										   ofType:@"plist"]]];

	[self setMachineType:[[CPSystemInformation machineType] substringFromIndex:1]];
	[self setComputerSerialNumber:[CPSystemInformation computerSerialNumber]];
	[self setComputerName:[CPSystemInformation computerName]];	
	
	// Empty the popupbutton
	[machineChooser removeAllItems];
	id humanMachineType = [CPSystemInformation humanMachineType];
	if ([humanMachineType isKindOfClass:[NSArray class]])
	{
		// Populate the popupbutton menu with possible machine models
		[machineChooser addItemsWithTitles:humanMachineType];
		id model = [[NSUserDefaults standardUserDefaults] objectForKey:MBLHumanMachineModelKey];
		if (model)
		{
			[self setMachineModel:model];
			[machineChooser selectItemWithTitle:model];
		}
		else
		{
			[self setMachineModel:[humanMachineType objectAtIndex:0]];
		}
	}
	else
	{
		[machineChooser addItemsWithTitles:[NSArray arrayWithObject:humanMachineType]];
		[self setMachineModel:humanMachineType];
	}
	
	if ([CPSystemInformation isPowerPC])
	{
		id date = [[NSUserDefaults standardUserDefaults] objectForKey:MBLBatteryPurchaseDateKey];
		if (date)
		{
			NSCalendarDate *cal = [date dateWithCalendarFormat:nil
													  timeZone:nil];
			[batteryManufactureDateLabel setStringValue:[cal descriptionWithCalendarFormat:NSLocalizedString(@"%m/%d/%Y", @"%m/%d/%Y")]];
			[self setBatteryDate:cal];
		}
		[batteryManufacturedLabel setStringValue:NSLocalizedString(@"Battery purchased:", @"Battery purchased:")];
	}
	else
	{
		[batteryManufactureDateLabel setDrawsBackground:NO];
		[batteryManufactureDateLabel setBordered:NO];
		[batteryManufactureDateLabel setEditable:NO];
	}
	
	if (computerName)
	{
		[hostNameLabel setStringValue:computerName];
		[hostNameBox setTitle:computerName];
	}
	else
	{
		[hostNameLabel setStringValue:NSLocalizedString(@"This Mac", @"This Mac")];
		[hostNameBox setTitle:NSLocalizedString(@"This Mac", @"This Mac")];
	}

/*
	BOOL drawsBackground = [[ownMachineCountLabel cell] drawsBackground];
	BOOL isBordered = [[ownMachineCountLabel cell] isBordered];
	NSColor *bgColor = [[ownMachineCountLabel cell] backgroundColor];
	NSColor *txColor = [[ownMachineCountLabel cell] textColor];
	NSFont *fnt = [[ownMachineCountLabel cell] font];
	
	[ownMachineCountLabel setCell:[[ELPillTextFieldCell alloc] init]];

	//[[ownMachineCountLabel cell] setDrawsBackground:drawsBackground];
	[[ownMachineCountLabel cell] setBordered:isBordered];
	[[ownMachineCountLabel cell] setBackgroundColor:bgColor];
	[[ownMachineCountLabel cell] setTextColor:txColor];
	[[ownMachineCountLabel cell] setFont:fnt];

	drawsBackground = [[ownModelCountLabel cell] drawsBackground];
	isBordered = [[ownModelCountLabel cell] isBordered];
	bgColor = [[ownModelCountLabel cell] backgroundColor];
	txColor = [[ownModelCountLabel cell] textColor];
	fnt = [[ownModelCountLabel cell] font];

	[ownModelCountLabel setCell:[[ELPillTextFieldCell alloc] init]];

	//[[ownModelCountLabel cell] setDrawsBackground:drawsBackground];
	[[ownModelCountLabel cell] setBordered:isBordered];
	[[ownModelCountLabel cell] setBackgroundColor:bgColor];
	[[ownModelCountLabel cell] setTextColor:txColor];
	[[ownModelCountLabel cell] setFont:fnt];
*/
	//[modelLabel setStringValue:machineType];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryManagerChanged:)
												 name:NSTableViewSelectionDidChangeNotification
											   object:nil];
}

@end