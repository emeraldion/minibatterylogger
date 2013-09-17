//
//  GeneralPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "GeneralPreferencePane.h"

extern NSString *MBLProbeIntervalKey;
extern NSString *MBLDisplayCustomIconKey;
extern NSString *MBLSaveSessionOnQuitKey;
extern NSString *MBLDisplayStatusItemKey;
extern NSString *MBLAutoSaveSessionsKey;
extern NSString *MBLHideDockIconKey;
extern NSString *MBLStartMonitoringAtLaunchKey;
extern NSString *MBLShowDesktopBatteryKey;

extern NSString *MBLProbeIntervalChangedNotification;
extern NSString *MBLDisplayCustomIconChangedNotification;
extern NSString *MBLDisplayStatusItemChangedNotification;

extern NSString *LSUIElementKey;

static NSString *LoginWindowKey = @"loginwindow";
static NSString *AutoLaunchedApplicationDictionaryKey = @"AutoLaunchedApplicationDictionary";

@class AppController;

@interface GeneralPreferencePane (Private)

- (NSDictionary *)dictionaryForLoginWindow;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

@end

@implementation GeneralPreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super initWithIdentifier:theIdentifier
								   label:theLabel
								category:theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"general"]];
	}
	return self;
}

- (void)mainViewDidLoad
{
	int interval = [self probeInterval];
	[timeSlider setIntValue:interval];
	[timeField setStringValue:[[NSValueTransformer valueTransformerForName:@"SecondsToMinutesTransformer"]
		transformedValue:[NSNumber numberWithInt:interval]]];
	
	[displayIconButton setState:[self shouldDisplayCustomIcon]];
	[saveOnQuitButton setState:[self shouldSaveOnQuit]];		
	[startupItemButton setState:[self isLoginItem]];
	[displayStatusItemButton setState:[self shouldDisplayStatusItem]];
	[showDesktopBatteryButton setState:[self shouldShowDesktopBattery]];
	[autoSaveSessionsButton setState:[self shouldAutoSaveSessions]];
	[hideDockIconButton setState:[self shouldHideDockIcon]];
	[startMonitoringAtLaunchButton setState:[self shouldStartMonitoringAtLaunch]];
	
	// If the "hide dock icon" is set to YES, the preference to change
	// the display of the status item should be disabled
	[displayStatusItemButton setEnabled:![self shouldHideDockIcon]];
}

#pragma mark === Preferences retrieval ===

- (int)probeInterval
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLProbeIntervalKey] intValue];	
}

- (BOOL)shouldDisplayCustomIcon
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLDisplayCustomIconKey] boolValue];	
}

- (BOOL)shouldStartMonitoringAtLaunch
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLStartMonitoringAtLaunchKey] boolValue];
}

- (BOOL)shouldDisplayStatusItem
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLDisplayStatusItemKey] boolValue];	
}

- (BOOL)shouldShowDesktopBattery
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLShowDesktopBatteryKey] boolValue];
}

- (BOOL)shouldSaveOnQuit
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLSaveSessionOnQuitKey] boolValue];	
}

- (BOOL)shouldAutoSaveSessions
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLAutoSaveSessionsKey] boolValue];	
}

- (BOOL)isLoginItem
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *dict = [defaults persistentDomainForName:LoginWindowKey];
	NSArray *login_items = [dict objectForKey:AutoLaunchedApplicationDictionaryKey];
	
	NSDictionary *own_login_item = [self dictionaryForLoginWindow];
	
	return [login_items containsObject:own_login_item];
}

- (BOOL)shouldHideDockIcon
{
	NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
	
	// Read the app's Info.plist dictionary
	NSDictionary *infoPlistDict = [[NSBundle mainBundle] infoDictionary];
	
	// Return the current value of LSUIElement
	return [[infoPlistDict valueForKey:LSUIElementKey] boolValue];	
}

#pragma mark === Actions ===

- (IBAction)changeSetting:(id)sender
{
	if (sender == displayIconButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]] 
												  forKey:MBLDisplayCustomIconKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:MBLDisplayCustomIconChangedNotification
															object:self];		
	}
	else if (sender == startMonitoringAtLaunchButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]] 
												  forKey:MBLStartMonitoringAtLaunchKey];
	}
	else if (sender == startupItemButton)
	{
		// Retrieve login items
		// They have to be read from loginwindow's domain
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary *dict = [[defaults persistentDomainForName:LoginWindowKey] mutableCopy];
		NSMutableArray *login_items = [[dict objectForKey:AutoLaunchedApplicationDictionaryKey] mutableCopy];
		
		NSDictionary *own_login_item = [self dictionaryForLoginWindow];
		
		BOOL modified = NO;
		if ([sender state] && ![login_items containsObject:own_login_item])
		{
			[login_items addObject:own_login_item];
			modified = YES;
		}
		else if (![sender state] && [login_items containsObject:own_login_item])
		{
			[login_items removeObject:own_login_item];
			modified = YES;
		}
		if (modified)
		{
			[dict setValue:login_items forKey:AutoLaunchedApplicationDictionaryKey];
			[defaults setPersistentDomain:dict forName:LoginWindowKey];
			[defaults synchronize];
		}
		[login_items release];
		[dict release];		
	}
	else if (sender == saveOnQuitButton)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSNumber numberWithBool:[sender state]] 
					 forKey:MBLSaveSessionOnQuitKey];
		[defaults synchronize];		
	}
	else if (sender == hideDockIconButton)
	{
		BOOL success = [AppController setHidesDockIcon:[sender state]];
		if (!success)
		{
			// Revert the button state on failure
			[sender setState:![sender state]];
		}
		else
		{
			// Enable the status menu if needed
			if ([sender state] &&
				![self shouldDisplayStatusItem])
			{
				[displayStatusItemButton setState:NSOnState];
				[self changeSetting:displayStatusItemButton];
			}
			// Disable the status menu preference button when hidden
			[displayStatusItemButton setEnabled:![sender state]];
		}
		
		// Ask for immediate relaunch
		NSBeginAlertSheet(NSLocalizedString(@"Restart required", @"Restart required"),
						  NSLocalizedString(@"Restart now", @"Restart now"),
						  NSLocalizedString(@"Later", @"Later"),
						  nil,
						  [[self mainView] window],
						  self,
						  @selector(sheetDidEnd:returnCode:contextInfo:),
						  nil,
						  NULL,
						  NSLocalizedString(@"This setting requires the restart of the application. You may restart the application right now or later.", @"This setting requires the restart of the application to be effective. You may restart the application right now or later."));		
	}
	else if (sender == displayStatusItemButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]] 
												  forKey:MBLDisplayStatusItemKey];
		[[NSNotificationCenter defaultCenter] postNotificationName:MBLDisplayStatusItemChangedNotification
															object:self];				
	}
	else if (sender == autoSaveSessionsButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]] 
												  forKey:MBLAutoSaveSessionsKey];
	}
	else if (sender == showDesktopBatteryButton)
	{
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]] 
												  forKey:MBLShowDesktopBatteryKey];
		if ([sender state])
		{
			[[AppController sharedController] showDesktopBatteryWindow];
		}
		else
		{
			[[AppController sharedController] hideDesktopBatteryWindow];
		}
	}	
}

- (IBAction)changeProbeInterval:(id)sender
{
	NSNumber *interval = [NSNumber numberWithInt:[sender intValue]];
	
	[timeField setStringValue:[[NSValueTransformer valueTransformerForName:@"SecondsToMinutesTransformer"]
		transformedValue:interval]];
	
	[[NSUserDefaults standardUserDefaults] setObject:interval 
											  forKey:MBLProbeIntervalKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLProbeIntervalChangedNotification
														object:self];	
}

@end

@implementation GeneralPreferencePane (Private)

- (NSDictionary *)dictionaryForLoginWindow
{
	return 	[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:NO], @"Hide",
		[[NSBundle mainBundle] bundlePath], @"Path",
		nil];	
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	if (returnCode == NSAlertDefaultReturn)
	{
		[NSApp relaunch:nil];
	}
}

@end

@implementation GeneralPreferencePane (NSCopyLinkMoveHandler)

- (void)fileManager:(NSFileManager *)manager willProcessPath:(NSString *)path
{
	//NSLog(@"%@", path);
}

- (BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	//NSLog(@"%@", errorInfo);
	return YES;
}

@end
