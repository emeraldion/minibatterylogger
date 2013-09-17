//
//  NotificationsPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//
//	2007-08-19	Added notification system chooser
//	2007-01-24	Introduced confirm dialog when setting alert values to zero
//				Added "Battery Dying" warning level
//

#import "NotificationsPreferencePane.h"

extern NSString *MBLLowAlertLevelKey;
extern NSString *MBLDyingAlertLevelKey;
extern NSString *MBLAlertModeKey;
extern NSString *MBLGrowlTestNotification;

@class AppController;

@interface NotificationsPreferencePane (Private)

- (void)_enableAlertSettings:(BOOL)yorn;

@end

@implementation NotificationsPreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super initWithIdentifier:theIdentifier
								   label:theLabel
								category:theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"alerts"]];
	}
	return self;
}

- (void)mainViewDidLoad
{
	int level = [self lowAlertLevel];
	[lowLevelSlider setIntValue:level];
	[lowLevelField setStringValue:[NSString stringWithFormat:@"%d%%", level]];

	level = [self dyingAlertLevel];
	[dyingLevelSlider setIntValue:level];
	[dyingLevelField setStringValue:[NSString stringWithFormat:@"%d%%", level]];
	
	MBLAlertMode mode = [self alertMode];
	// This is a workaround to support <= 10.4
	[alertModeChooser selectItemAtIndex:[alertModeChooser indexOfItemWithTag:mode]];
	
	[self _enableAlertSettings:(mode != MBLAlertModeNone)];
}

- (int)lowAlertLevel
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLLowAlertLevelKey] intValue];
}

- (int)dyingAlertLevel
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLDyingAlertLevelKey] intValue];
}

- (MBLAlertMode)alertMode
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLAlertModeKey] intValue];
}

- (IBAction)changeLowAlertLevel:(id)sender
{
	[self changeLevel:sender
				field:lowLevelField
				  key:MBLLowAlertLevelKey];
}

- (IBAction)changeDyingAlertLevel:(id)sender
{
	[self changeLevel:sender
				field:dyingLevelField
				  key:MBLDyingAlertLevelKey];
}

- (IBAction)changeAlertMode:(id)sender
{
	MBLAlertMode mode = [[sender selectedItem] tag];
	
	[self _enableAlertSettings:(mode != MBLAlertModeNone)];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:mode]
											  forKey:MBLAlertModeKey];
}

- (IBAction)testAlert:(id)sender
{
	[[AppController sharedController] notify:MBLGrowlTestNotification
									   title:NSLocalizedString(@"Test Notification", @"Test Notification")
									 details:NSLocalizedString(@"This is a test notification", @"This is a test notification")];
}

- (void)changeLevel:(id)sender field:(NSTextField *)field key:(NSString *)key
{
#pragma unused (sender)
	
	int level = [sender intValue];
	
	if (level == 0)
	{
		NSDictionary *dict = [[NSDictionary dictionaryWithObjectsAndKeys:
			[[NSUserDefaults standardUserDefaults] objectForKey:key], @"oldLevel",
			sender, @"slider",
			field, @"field",
			nil] retain];
		
		NSBeginAlertSheet(NSLocalizedString(@"Warning disabled", @"Warning disabled"),
						  NSLocalizedString(@"OK", @"OK"),
						  NSLocalizedString(@"Cancel", @"Cancel"), 
						  nil,
						  [[self mainView] window],
						  self,
						  @selector(sheetDidEnd:returnCode:contextInfo:),
						  nil,
						  (void *)dict,
						  NSLocalizedString(@"Setting the value to zero will disable the warnings. Are you sure?", @"Setting the value to zero will disable the warnings. Are you sure?"));
	}
	else
	{
		[field setStringValue:[NSString stringWithFormat:@"%d%%", level]];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:level]
												  forKey:key];
	}
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	if (returnCode == NSAlertAlternateReturn)
	{
		NSDictionary *dict = (NSDictionary *)contextInfo;
		NSSlider *slider = (NSSlider *)[dict valueForKey:@"slider"];
		NSTextField *field = (NSTextField *)[dict valueForKey:@"field"];
		int oldLevel = [[dict valueForKey:@"oldLevel"] intValue];

		// Revert old value
		[slider setIntValue:oldLevel];
		[field setStringValue:[NSString stringWithFormat:@"%d%%", oldLevel]];
		
		// Cleanup
		[dict release];
	}
}

@end

@implementation NotificationsPreferencePane (Private)

- (void)_enableAlertSettings:(BOOL)yorn
{
	[testButton setEnabled:yorn];
	[lowLevelSlider setEnabled:yorn];
	[dyingLevelSlider setEnabled:yorn];
}

@end