//
//  RecallController.m
//  MiniBatteryLogger
//
//  Created by delphine on 15-05-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "RecallController.h"
#import "CPSystemInformation.h"

static NSString *MBLBatteryRecallCountryCodeKey			= @"MBLBatteryRecallCountryCode";
static NSString *MBLBatteryRecallURL					= @"https://support.apple.com/ibook_powerbook/batteryexchange/?country=%@&sn=%@&battery=%@&func=continue&lang=en";
static NSString *MBLBatteryRecallFAQURL					= @"http://www.apple.com/support/batteryexchange/2006/faq/";

static int MBLBatteryRecallBatterySerialNumberLength	= 12;
static int MBLBatteryRecallComputerSerialNumberLength	= 11;

@implementation NSString (BatteryRecallExtensions)

/* Returns YES if the serial number is eligible for the battery exchange program */
- (BOOL)isEligibleForiBookNPowerBookExchangeProgram
{
/*
	Computer Model			Battery Model		Battery serial number range
    --------------------	-------------		---------------------------------------------
	12-inch iBook G4		A1061				ZZ338 - ZZ427
												3K429 - 3K611
												6C519 - 6C552 ending with S9WA, S9WC or S9WD

	12-inch PowerBook G4	A1079				ZZ411 - ZZ427
												3K428 - 3K611

	15-inch PowerBook G4	A107, A1148			3K425 - 3K601
												6N530 - 6N551 ending with THTA, THTB, or THTC
												6N601 ending with THTC
*/
	int i;
	id theObj;

	// Easy stuff; here we just need to check if a string falls between two boundaries
	if (
		/* Range ZZ338 - ZZ427 */
		([self caseInsensitiveCompare:@"ZZ337ZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"ZZ4280000000"] == NSOrderedAscending) ||

		/* Range 3K429 - 3K611 */
		([self caseInsensitiveCompare:@"3K428ZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"3K6120000000"] == NSOrderedAscending) ||
		
		/* Range ZZ411 - ZZ427 */
		([self caseInsensitiveCompare:@"ZZ410ZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"ZZ4280000000"] == NSOrderedAscending) ||
		
		/* Range 3K428 - 3K611 */
		([self caseInsensitiveCompare:@"3K427ZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"3K6120000000"] == NSOrderedAscending) ||
		
		/* Range 3K425 - 3K601 */
		([self caseInsensitiveCompare:@"3K427ZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"3K6120000000"] == NSOrderedAscending)
		)
	{
		return YES;
	}
	
	// Now we also have to check if a string ends with a given suffix
	if (
		/* Range 6C519 - 6C552 ending with S9WA, S9WC or S9WD */
		([self caseInsensitiveCompare:@"6C518ZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"6C5530000000"] == NSOrderedAscending))
	{
		NSArray *suffixes = [NSArray arrayWithObjects:@"S9WA",
			@"S9WC",
			@"S9WD",
			nil];
		for (i = 0; i < [suffixes count]; i++)
		{
			theObj = [suffixes objectAtIndex:i];
			if ([self rangeOfString:theObj options:NSCaseInsensitiveSearch].location ==
				[self length] - [theObj length])
			{
				return YES;
			}
		}
		return NO;
	}
	
	if (
		/* Range 6N530 - 6N551 ending with THTA, THTB, or THTC */
		([self caseInsensitiveCompare:@"6N52ZZZZZZZZ"] == NSOrderedDescending &&
		 [self caseInsensitiveCompare:@"6N5520000000"] == NSOrderedAscending))
	{
		NSArray *suffixes = [NSArray arrayWithObjects:@"THTA",
			@"THTB",
			@"THTC",
			nil];
		for (i = 0; i < [suffixes count]; i++)
		{
			theObj = [suffixes objectAtIndex:i];
			if ([self rangeOfString:theObj options:NSCaseInsensitiveSearch].location ==
				[self length] - [theObj length])
			{
				return YES;
			}
		}
		return NO;
	}
	
	// This one is easy; just check if a string begins and ends with given strings
	if (
		/* Range 6N601 ending with THTC */
		([self rangeOfString:@"6N601" options:NSCaseInsensitiveSearch].location == 0) &&
		([self rangeOfString:@"THTC" options:NSCaseInsensitiveSearch].location == [self length] - [@"THTC" length])
		)
	{
		return YES;
	}		
	
	return NO;
}

@end

@implementation RecallController

- (id)init
{
	if (self = [super initWithWindowNibName:@"Recall"])
	{
		countriesDict = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RecallCountries"
																									ofType:@"plist"]] retain];
	}
	return self;
}

- (void)windowDidLoad
{
	// Setup User Interface
	
	[computerSerialNumberField setStringValue:[CPSystemInformation computerSerialNumber]];
	
	[countryChooser removeAllItems];
	[countryChooser addItemsWithTitles:[[countriesDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
	NSString *cCode;
	if (cCode = [[NSUserDefaults standardUserDefaults] objectForKey:MBLBatteryRecallCountryCodeKey])
	{
		NSArray *countries = [countriesDict allKeysForObject:cCode];
		if (countries != nil &&
			[countries count] > 0)
		{
			NSString *country = [countries objectAtIndex:0];
			if ([countryChooser itemWithTitle:country] != nil)
			{
				[countryChooser selectItemWithTitle:country];
			}
		}
	}
}

- (void)setAppController:(AppController *)controller
{
	appController = controller;
}

- (IBAction)onlineHelp:(id)sender
{
	[appController onlineHelp:sender];
}

- (IBAction)moreInfo:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:MBLBatteryRecallFAQURL]];
}

- (IBAction)countryChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[countriesDict objectForKey:[sender titleOfSelectedItem]]
											  forKey:MBLBatteryRecallCountryCodeKey];
}

- (IBAction)checkiBookNPowerBookBatteryExchangeEligibility:(id)sender
{
	if ([[batterySerialNumberField stringValue] length] != MBLBatteryRecallBatterySerialNumberLength)
	{
		NSBeep();
		[[self window] makeFirstResponder:batterySerialNumberField]; 
	}
	else if ([[computerSerialNumberField stringValue] length] != MBLBatteryRecallComputerSerialNumberLength)
	{
		NSBeep();
		[[self window] makeFirstResponder:computerSerialNumberField]; 
	}
	else
	{
		if ([[batterySerialNumberField stringValue] isEligibleForiBookNPowerBookExchangeProgram])
		{
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:MBLBatteryRecallURL,
				[countriesDict objectForKey:[countryChooser titleOfSelectedItem]],
				[CPSystemInformation computerSerialNumber],
				[batterySerialNumberField stringValue]]];
		}
		else
		{
			NSBeep();
			NSBeginAlertSheet(NSLocalizedString(@"Not Eligible", @"Not Eligible"),
							  NSLocalizedString(@"OK", @"OK"),
							  nil,
							  nil,
							  [self window],
							  self,
							  nil,
							  nil,
							  NULL,
							  NSLocalizedString(@"This battery is not eligible for the iBook G4 and PowerBook G4 Battery Exchange program", @"This battery is not eligible for the iBook G4 and PowerBook G4 Battery Exchange program"));
		}
	}
}

@end
