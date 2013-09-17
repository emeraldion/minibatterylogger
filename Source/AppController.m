//
//  AppController.m
//  MiniBatteryLogger
//
//  Created by delphine on 26-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "AppController.h"
#import "NSApplication+MBLUtils.h"
#import "NSArray+MBLUtils.h"
#import "MBLTypes.h"
#import "MBLLicense.h"
#import "SharingPreferencePane.h"
#import "NSURL+SGUtils.h"
#import "DesktopBatteryController.h"
#import "MigrationAgent.h"

#define FEEDBACK_URL @"mailto:emeraldion@emeraldion.it?subject=MiniBatteryLogger%%20Feedback%%20(%@)"
#define WEBSITE_URL @"http://www.emeraldion.it/software/macosx/minibatterylogger.html?me=%@"
#define GGROUP_URL @"http://groups.google.com/group/minibatterylogger/"
#define EME_URL @"http://www.emeraldion.it/?me=%@"

// Time interval allowed before evaluation period expires (set to 30 days)
#define EVALUATION_PERIOD_INTERVAL (3600 * 24 * 30)

// Path of Grab effect sound file
#define GRAB_SOUND_PATH @"/System/Library/Components/CoreAudio.component/Contents/Resources/SystemSounds/system/Grab.aif"

#pragma mark === Static Strings ===

// Sizes
static NSString *MBLSidebarSizeKey		= @"MBLSidebarSize";
//static NSString *MBLSidebarHiddenKey	= @"MBLSidebarHidden";

// Toolbar identifiers
static NSString *MBLMainToolbarIdentifier				= @"MBLMainToolbar";
static NSString *MBLSwitchViewToolbarItemIdentifier		= @"MBLSwitchViewToolbarItem";
static NSString *MBLZoomToolbarItemIdentifier			= @"MBLZoomToolbarItem";
static NSString *MBLNavigatorToolbarItemIdentifier		= @"MBLNavigatorToolbarItem";
static NSString *MBLInspectorToolbarItemIdentifier		= @"MBLInspectorToolbarItem";
static NSString *MBLOpenInConsoleToolbarItemIdentifier	= @"MBLOpenInConsoleToolbarItem";
static NSString *MBLStopResumeToolbarItemIdentifier		= @"MBLStopResumeToolbarItem";
static NSString *MBLClearLogToolbarItemIdentifier		= @"MBLClearLogToolbarItem";
static NSString *MBLSessionsToolbarItemIdentifier		= @"MBLSessionsToolbarItem";
static NSString *MBLBalloonToolbarItemIdentifier		= @"MBLBalloonToolbarItem";
static NSString *MBLEnergyPrefsToolbarItemIdentifier	= @"MBLEnergyPrefsToolbarItem";
static NSString *MBLDiagnosticsToolbarItemIdentifier	= @"MBLDiagnosticsToolbarItem";

// Growl notification names
static NSString *MBLGrowlChargeStartedNotification;
static NSString *MBLGrowlChargeStoppedNotification;
static NSString *MBLGrowlBatteryLowNotification;
static NSString *MBLGrowlPowerSourceChangedNotification;
static NSString *MBLGrowlMonitoringStartedNotification;
static NSString *MBLGrowlMonitoringStoppedNotification;
static NSString *MBLGrowlBatteryExhaustedNotification;
static NSString *MBLGrowlSnapshotGrabbedNotification;
static NSString *MBLGrowlBatteryChangedNotification;
static NSString *MBLGrowlSharingServiceFoundNotification;
static NSString *MBLGrowlSharingServiceRemovedNotification;
NSString *MBLGrowlTestNotification;

// Misc defaults keys
static NSString *MBLDefaultsReminderCounterKey		= @"MBLRegistrationReminder";
static NSString *MBLDidPerformMigrationKey			= @"MBLDidPerformMigration";

// Cache name
static NSString *MBLCacheName = @"LnBsdW1lcmlhcmM=";

// Application name
static NSString *MBLApplicationNameFormat = @"MiniBatteryLogger %@";

//static int kMBLSidebarMinWidth		= 46;
//static int kMBLChartMinWidth		= 450;

id _AppControllerSharedInstance = nil;

@class DataTransformer;
@class BooleanValueTransformer;
@class AOSegmentedControl;
@class LogArrayController;
@class AMPreferenceWindowController;
@class CPSystemInformation;
@class MBLBatteryManagerCell;
@class RemoteBatteryManager;
@class BonjourBatteryManager;

@class SharedArchive;

@interface AppController (Private)

- (NSData *)_notificationIconData;
- (void)_updateDockIcon;
- (void)_updateViewChooserMenuItems;
- (void)_updateZoomShiftControls;
- (void) sheetDidEnd:(NSWindow *)sheet
		  returnCode:(int)retCode
		 contextInfo:(void *)cInfo;
- (void) updateSnapshots;
- (NSArray *) batteryPatternsArray;
- (void) _registerForPowerChanges:(id)source;
- (void)localizeUIElements;

#pragma mark === Private setters ===

- (void)setSnapshots:(BatterySnapshots *)s;
- (void)setPreferencesController:(AMPreferenceWindowController *)ctl;

#pragma mark === Registration handling ===

- (BOOL)_shouldShowRegistrationReminder;
- (void)showRegistrationReminder;
- (BOOL)registerToUser:(NSString *)user key:(NSString *)key;
- (void)deRegister;

#pragma mark === GrowlApplicationBridgeDelegate Bridge methods ===

- (void)notify:(NSString *)type
		 title:(NSString *)title
	   details:(NSString *)details;
- (void)appendToLog:(NSString *)line;
- (void)initializeToolbar;

#pragma mark === Status menu ===

- (void)activateStatusMenu;
- (void)removeStatusMenu;
- (void)deselectStatusModeItems;
- (void)markStatusModeItemWithTag:(int)tag;
- (void)removeRedundantStatusMenuItems;

#pragma mark === Battery Properties Change Handlers ===

- (void)chargingChanged;
- (void)pluggedChanged;
- (void)chargeChanged;
- (void)maxCapacityChanged;

#pragma mark === Remote Services ===

- (void)attachStartupRemoteConnections;
- (void)removeManager:(BatteryManager *)mgr;
- (BOOL)registerRemoteService:(BatteryManager *)remote;
- (void)unregisterRemoteService:(BatteryManager *)remote;
- (BOOL)isRegisteredRemoteService:(BatteryManager *)remote;

@end

@implementation AppController

- (oneway void)setSharingService:(id)theService
{
	[theService setProtocolForProxy:@protocol(MBLSharingMethods)];
	
	[theService retain];
	[sharingService release];
	sharingService = theService;
	
}

+ (id)sharedController
{
	return _AppControllerSharedInstance;
}

+ (void)initialize
{
	/* Registering Standard User Defaults */
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"userdefaults"
																														   ofType:@"plist"]];
	/* Exporting */
	[defaultValues setObject:NSHomeDirectory() forKey:MBLExportFolderKey];	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	// Register default values
	[defaults registerDefaults:defaultValues];
	
	// Apply immediately
	[defaults synchronize];	
	
	/* Growl Notification Names */
	MBLGrowlChargeStartedNotification			= NSLocalizedString(@"Charge Started", @"Charge Started");
	MBLGrowlChargeStoppedNotification			= NSLocalizedString(@"Charge Stopped", @"Charge Stopped");
	MBLGrowlBatteryLowNotification				= NSLocalizedString(@"Battery Low", @"Battery Low");
	MBLGrowlPowerSourceChangedNotification		= NSLocalizedString(@"Power Source Changed", @"Power Source Changed");
	MBLGrowlMonitoringStartedNotification		= NSLocalizedString(@"Monitoring Started", @"Monitoring Started");
	MBLGrowlMonitoringStoppedNotification		= NSLocalizedString(@"Monitoring Stopped", @"Monitoring Stopped");
	MBLGrowlBatteryExhaustedNotification		= NSLocalizedString(@"Battery Exhausted", @"Battery Exhausted");	
	MBLGrowlSnapshotGrabbedNotification			= NSLocalizedString(@"Snapshot Grabbed", @"Snapshot Grabbed");
	MBLGrowlBatteryChangedNotification			= NSLocalizedString(@"Battery Changed", @"Battery Changed");
	MBLGrowlSharingServiceFoundNotification		= NSLocalizedString(@"Found Shared Battery", @"Found Shared Battery");
	MBLGrowlSharingServiceRemovedNotification	= NSLocalizedString(@"Shared Battery Removed", @"Shared Battery Removed");
	MBLGrowlTestNotification					= NSLocalizedString(@"Test Notification", @"Test Notification");

	/* Registering Value Transformers */
	[NSValueTransformer setValueTransformer:[[[DataTransformer alloc] init] autorelease]
									forName:@"DataTransformer"];

	[NSValueTransformer setValueTransformer:[[[StatusLedValueTransformer alloc] initWithMode:MBLStatusLedOnOffMode] autorelease]
									forName:@"OnOffLedTransformer"];

	[NSValueTransformer setValueTransformer:[[[StatusLedValueTransformer alloc] initWithMode:MBLStatusLedGoodBadMode] autorelease]
									forName:@"GoodBadLedTransformer"];

	[NSValueTransformer setValueTransformer:[[[SecondsToMinutesTransformer alloc] init] autorelease]
									forName:@"SecondsToMinutesTransformer"];
	
	[NSValueTransformer setValueTransformer:[[[SecondsToMinutesTransformer alloc] initWithMode:MBLSecondsToMinutesTransformerCompactMode] autorelease]
									forName:@"SecondsToMinutesCompactTransformer"];
	
	[NSValueTransformer setValueTransformer:[[[SecondsToMinutesTransformer alloc] initWithMode:MBLSecondsToMinutesTransformerInfinityMode] autorelease]
									forName:@"SecondsToMinutesInfinityTransformer"];
	
	[NSValueTransformer setValueTransformer:[[[BooleanValueTransformer alloc] init] autorelease]
									forName:@"BooleanValueTransformer"];
	
}

- (void)dealloc
{	
	[statusMenuItems release];
	[auxStatusMenuItems release];
	
	[speechSynth release];
	
	[snapshots release];
	[batteryManagers release];
	[preferenceController release];
	[aboutController release];
	[remoteConnectionController release];
	[SessionPreviewController release];
	
	[dictionaryForGrowl release];
	[logger release];
	[helpAnchors release];
	[toolbar release];
	[statusItem release];
	[currentSessions release];
	[remoteServices release];

	[sharingService release];
	[loadedSessions release];

	[_license release];

	[super dealloc];
}

+ (BOOL)setHidesDockIcon:(BOOL)yorn
{
	NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *infoPlistPath = [[mainBundlePath stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Info.plist"];
	
	// Read the app's Info.plist dictionary
	NSDictionary *infoPlistDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
	
	// Change the value of LSUIElement
	[infoPlistDict setValue:[NSNumber numberWithBool:yorn] 
					 forKey:LSUIElementKey];
	
	BOOL success;
	success = [infoPlistDict writeToFile:infoPlistPath
							  atomically:YES];
	if (success)
	{
		// Adjust the preference in defaults
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:[NSNumber numberWithBool:yorn]
					 forKey:MBLHideDockIconKey];
		[defaults synchronize];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		// Hack to force the Info.plist to be read:
		// touch the app's main bundle
		// See <http://www.cocoabuilder.com/archive/message/cocoa/2003/11/1/85001>
		[fileManager changeFileAttributes:[NSDictionary dictionaryWithObject:[NSDate date]
																	  forKey:NSFileModificationDate]
								   atPath:mainBundlePath];
	}
	return success;
}

+ (void)checkDockIcon
{
	BOOL masterValue = [[[NSUserDefaults standardUserDefaults] objectForKey:MBLHideDockIconKey] boolValue];

	if (masterValue)
	{
		// Ensure that the status item is enabled
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
												  forKey:MBLDisplayStatusItemKey];
	}
	
	NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *infoPlistPath = [[mainBundlePath stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Info.plist"];
	
	// Read the app's Info.plist dictionary
	NSDictionary *infoPlistDict = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
	
	BOOL targetValue = [[infoPlistDict valueForKey:LSUIElementKey] boolValue];
	
	if (masterValue != targetValue)
	{
		// Change target value and relaunch the app
		[infoPlistDict setValue:[NSNumber numberWithBool:masterValue]
						 forKey:LSUIElementKey];
		// Write to file
		BOOL success = [infoPlistDict writeToFile:infoPlistPath
									   atomically:YES];
		if (success)
		{
			NSFileManager *fileManager = [NSFileManager defaultManager];
			
			// Hack to force the Info.plist to be read:
			// touch the app's main bundle
			// See <http://www.cocoabuilder.com/archive/message/cocoa/2003/11/1/85001>
			[fileManager changeFileAttributes:[NSDictionary dictionaryWithObject:[NSDate date]
																		  forKey:NSFileModificationDate]	
									   atPath:mainBundlePath];
			
			// Relaunch the application
			[NSApp relaunch:nil];
		}
		else
		{
			NSLog(@"Error: can't write Info.plist");
		}
	}	
}

+ (NSString *)applicationName
{
	return [NSString stringWithFormat:MBLApplicationNameFormat, [self applicationVersion]];

}

+ (NSString *)applicationVersion
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

- (void)showDesktopBatteryWindow
{
	if (!desktopBatteryController)
	{
		desktopBatteryController = [[DesktopBatteryController alloc] initWithController:batteryController];
		/*
		[[desktopBatteryController label] bind:@"value"
									  toObject:managerController
								   withKeyPath:@"selection.name"
									   options:nil];
		 */
	}
	[desktopBatteryController showWindow:nil];
}

- (void)hideDesktopBatteryWindow
{
	if (desktopBatteryController)
	{
		[[desktopBatteryController window] orderOut:nil];
	}
}

- (void)handleSleepWakeShutdown:(NSNotification *)note
{
	NSString *msg;
	if ([[note name] isEqual:NSWorkspaceDidWakeNotification])
	{
		msg = NSLocalizedString(@"+++ Awake from Sleep +++", @"+++ Awake from Sleep +++");
	}
	else if ([[note name] isEqual:NSWorkspaceWillSleepNotification])
	{
		msg = NSLocalizedString(@"--- Going to Sleep ---", @"--- Going to Sleep ---");
	}
	else if ([[note name] isEqual:NSWorkspaceWillPowerOffNotification])
	{
		msg = NSLocalizedString(@"=== System is shutting down ===", @"=== System is shutting down ===");
	}
	[self appendToLog:msg];
	[chartView setNeedsDisplay:YES];
	
	// Auto save sessions if requested
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:MBLAutoSaveSessionsKey] boolValue])
	{
		[self saveSessions:nil];
	}	
}

- (void)probeIntervalChanged:(NSNotification *)note
{
}

- (void)batteryPropertiesChanged:(NSNotification *)notif
{
	if ([[notif name] isEqualToString:MBLBatteryPropertiesChangedNotification])
	{
		batteryManagers = [managerController content];
		
		if ([batteryManagers count] < 1)
			return;
		
		// Get battery manager index
		//int index = [batteryManagers indexOfObject:[notif object]];
		
		if ([notif object] == batteryManager)
		{
			// Request redraw
			[chartView setNeedsDisplay:YES];
			
			if ([battery charge] != charge)
			{
				[self chargeChanged];
			}
			if ([battery isPlugged] != plugged)
			{
				[self pluggedChanged];
			}
			if ([battery isCharging] != charging)
			{
				[self chargingChanged];
			}
			if ([battery maxCapacity] != maxCapacity)
			{
				[self maxCapacityChanged];
			}
			NSString *msg = [(BatteryEvent *)[notif userInfo] description];
			[self appendToLog:msg];
			
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLDisplayCustomIconKey] boolValue])
			{
				[self _updateDockIcon];
			}
		}
	}
	else if ([[notif name] isEqualToString:MBLBatteryManagerPropertiesChangedNotification])
	{
		[managersList reloadData];
	}
	else if ([[notif name] isEqualToString:MBLBatteryManagerRemoteConnectionErrorNotification])
	{
		[self appendToLog:[NSString stringWithFormat:NSLocalizedString(@"### Error connecting to remote battery at address %@ ###", @"### Error connecting to remote battery at address %@ ###"),
			[[notif object] address]]];

		[self unregisterRemoteService:[notif object]];
		[self removeManager:[notif object]];
	}
}

- (void)handleNotification:(NSNotification *)notif
{
	if ([[notif name] isEqual:MBLTableViewMouseExitedNotification])
	{
		//NSLog(@"Received notification: %@", [notif name]);
		if ([notif object] == sessionsView)
		{
			//NSLog(@"Dismissing window");
			[sessionPreviewController dismissWindow:self];
		}
	}
	else if ([[notif name] isEqual:NSTableViewSelectionIsChangingNotification])
	{
		if ([notif object] == managersList)
		{
			BatteryManager *mgr = [[managerController selectedObjects] objectAtIndex:0];
			if ([mgr serviceUID] == nil)
			{
				// Revert to previously selected manager
				[managerController setSelectedObjects:[NSArray arrayWithObject:batteryManager]];
			}			
		}
	}
	else if ([[notif name] isEqual:NSTableViewSelectionDidChangeNotification])
	{
		if ([notif object] == managersList)
		{
			// Save current snapshots
			[snapshots saveToFileForBattery:[batteryManager serviceUID] atIndex:[batteryManager index]];
			
			// Unload sessions for this battery
			[self unloadSessions];
			
			batteryManagers = [managerController content];
			
			// Get battery manager index
			int index = [managerController selectionIndex];
			
			if (index < [LocalBatteryManager installedBatteries])
			{
				// Store it for later
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:index]
														  forKey:MBLLastLocalBatteryIndexKey];
			}
			
			// Swizzle battery to current manager's
			batteryManager = [batteryManagers objectAtIndex:index];
			
			// Swizzle battery to current manager's
			battery = [batteryManager battery];
			
			// Reset observed battery properties
			charge = [battery charge];
			maxCapacity = [battery maxCapacity];
			plugged = [battery isPlugged];
			charging = [battery isCharging];
			
			if (![loadedSessions objectForKey:[batteryManager serviceUID]])
			{
				// Load previous sessions
				[NSThread detachNewThreadSelector:@selector(loadSessions:)
										 toTarget:self
									   withObject:batteryManager];
			}
			else
			{
				// Just put them into the belly of the controller
				[sessionsController setContent:[NSMutableArray arrayWithArray:[batteryManager sessions]]];
			}
			
			// Load past snapshots from disk
			[self setSnapshots:[BatterySnapshots snapshotsForBattery:[batteryManager serviceUID] atIndex:[batteryManager index]]];
			
			// Fill the snapshots array controller
			[snapshotsController setContent:[snapshots shots]];
			
			[self updateSnapshots];
			
			if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLDisplayCustomIconKey] boolValue])
			{
				[self _updateDockIcon];
			}			
			
			NSString *details = [NSString stringWithFormat:NSLocalizedString(@"Now monitoring battery %d on %@", @"Now monitoring battery %d on %@"),
				[batteryManager index] + 1,
				[[batteryManager name] objectAtIndex:0]];
			
			[self notify:MBLGrowlBatteryChangedNotification
				   title:MBLGrowlBatteryChangedNotification
				 details:details];

			NSString *msg = [NSString stringWithFormat:@"=== %@ ===", details];
			[self appendToLog:msg];
		}
	}
	else if ([[notif name] isEqualToString:MBLAdvertiseServiceChangedNotification])
	{
		//NSLog(@"Advertise: %@", [[notif object] shouldAdvertiseService] ? @"yes" : @"no");
		[sharingService setBatteryServerPublishes:[(SharingPreferencePane *)[notif object] shouldAdvertiseService]];
	}
	else if ([[notif name] isEqualToString:MBLShareOwnDataChangedNotification])
	{
		//NSLog(@"Share: %@", [[notif object] shouldShareOwnData] ? @"yes" : @"no");
		if ([(SharingPreferencePane *)[notif object] shouldShareOwnData])
		{
			[sharingService startBatteryServer];
		}
		else
		{
			[sharingService stopBatteryServer];
		}
	}
	else if ([[notif name] isEqualToString:MBLLookForSharedDataChangedNotification])
	{
		//NSLog(@"Look: %@", [[notif object] shouldLookForSharedData] ? @"yes" : @"no");
		if ([(SharingPreferencePane *)[notif object] shouldLookForSharedData])
		{
			if (!serviceBrowser)
			{
				serviceBrowser = [[NSNetServiceBrowser alloc] init];
				[serviceBrowser setDelegate:self];
			}
			[serviceBrowser searchForServicesOfType:@"_mbl-battd._tcp." inDomain:@""];
		}
		else
		{
			[serviceBrowser stop];
			
			// Remove all remote managers
			[self disconnectAllManagers:nil];
		}
	}
}

- (void)handleDisplayCustomIconChange:(NSNotification *)note
{
	if ([(GeneralPreferencePane *)[note object] shouldDisplayCustomIcon])
	{
		[self _updateDockIcon];
	}
	else
	{
		[NSApp setApplicationIconImage:[NSImage imageNamed:@"MiniBatteryLogger"]];
	}	
}

- (void)handleDisplayStatusItemChange:(NSNotification *)note
{
	displayStatusItem = [(GeneralPreferencePane *)[note object] shouldDisplayStatusItem];
	if (displayStatusItem)
	{
		[self activateStatusMenu];
	}
	else
	{
		[self removeStatusMenu];
	}
}

- (void)unloadSessions
{
	// Auto save sessions if requested
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:MBLAutoSaveSessionsKey] boolValue])
	{
		[self saveSessions:nil];
	}	
}

- (void)loadSessions:(id)manager
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (manager)
	{
		// Load saved sessions
		NSArray *pastSessions = [MonitoringSession loadSessionsForBattery:[manager serviceUID]
																  atIndex:[manager index]];
		
		// Add saved sessions
		[manager appendSessions:pastSessions];

		if (manager == batteryManager)
		{
			// Put inside sessions array controller
			[sessionsController setContent:[NSMutableArray arrayWithArray:[manager sessions]]];
		}
		
		if ([manager serviceUID] != nil)
		{
			// Store in the dictionary
			[loadedSessions setObject:[NSNumber numberWithBool:YES] forKey:[manager serviceUID]];
		}	
	}
	[pool release];
}

#pragma mark === Accessors ===

- (BOOL)isRegistered
{
	BOOL registered = NO;
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:MBLDefaultsRegisteredUserKey];
	NSString *key = [[NSUserDefaults standardUserDefaults] objectForKey:MBLDefaultsRegistrationKeyKey];
	if (username && key)
	{
		MBLLicense *license = [MBLLicense licenseForUsername:username key:key];
		if ([license isValid] &&
			[[license startDate] compare:[NSDate date]] == NSOrderedAscending &&
			[[license expirationDate] compare:[NSDate date]] == NSOrderedDescending)
		{
			[self setLicense:license];
			registered = YES;
		}		
	}
	return registered;
}

- (void)setLicense:(MBLLicense *)license
{
	[license retain];
	[_license release];
	_license = license;
}

- (NSString *)registeredUser
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:MBLDefaultsRegisteredUserKey];
}

- (Battery *)battery
{
	return battery;
}
- (BatteryManager *)batteryManager
{
	return batteryManager;
}

#pragma mark === Actions ===

- (IBAction)toggleBatteryStatus:(id)sender
{
	RBSplitSubview *statusdeck = [batteryStatusSplitView subviewAtPosition:1];
	BOOL hidden = [statusdeck isCollapsed];
	if (hidden)
	{
		[batteryStatusToggler setToolTip:NSLocalizedString(@"Hide Battery Status", @"Hide Battery Status")];
		[batteryStatusToggler setState:NSOffState];
		[statusdeck expandWithAnimation];
	}
	else
	{
		[batteryStatusToggler setToolTip:NSLocalizedString(@"Show Battery Status", @"Show Battery Status")];
		[batteryStatusToggler setState:NSOnState];
		[statusdeck collapseWithAnimation];
	}
}

- (IBAction)toggleSidebar:(id)sender
{
	RBSplitSubview *bar = [sidebarSplitView subviewAtPosition:0];
	BOOL hidden = [bar isCollapsed];
	if (hidden)
	{
		[bar expandWithAnimation];
	}
	else
	{
		[bar collapseWithAnimation];
	}
}

- (IBAction)showWindow:(id)sender
{
	// Show window if hidden
	if (![window isVisible])
	{
		[window makeKeyAndOrderFront:sender];
	}
	// Activate app if not active
	if (![NSApp isActive])
	{
		[NSApp activateIgnoringOtherApps:YES];
	}
}

- (IBAction)showBatteryDetails:(id)sender
{
	// Activate app if not active
	if (![NSApp isActive])
	{
		[NSApp activateIgnoringOtherApps:YES];
	}
	[detailsPanel makeKeyAndOrderFront:sender];
}

- (IBAction)addSnapshot:(id)sender
{
	// Add a new snapshot to the array controller's content
	// This will trigger redrawing in the snapshots view
	BatterySnapshot *shot = [[BatterySnapshot alloc] initWithBattery:battery];

	[snapshotsController addObject:shot];
	[shot release];
	
	// Play the sound of Grab.app
	NSSound *grabSound = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:GRAB_SOUND_PATH])
	{
		grabSound = [[NSSound alloc] initWithContentsOfFile:GRAB_SOUND_PATH
												byReference:YES];
	}
	[grabSound play];
	[grabSound release];
}

- (IBAction)sendFeedback:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:FEEDBACK_URL,
			[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
}

- (IBAction)switchView:(id)sender
{
	[tabView selectTabViewItemAtIndex:[sender selectedSegment]];
	[self _updateZoomShiftControls];
	[self _updateViewChooserMenuItems];
}

- (IBAction)switchToView:(id)sender
{
	int tag = [sender tag];
	[viewSwitcher setSelectedSegment:tag];
	[tabView selectTabViewItemAtIndex:tag];

	[self _updateZoomShiftControls];
	[self _updateViewChooserMenuItems];
}

- (IBAction)zoomChartInOut:(id)sender
{
	int sel = [sender selectedSegment];
	if (sel == 2)
	{
		[chartView zoomOut:sender];
	}
	else if (sel == 1)
	{
		[chartView zoomToFit:sender];
	}
	else
	{
		[chartView zoomIn:sender];
	}
	[self _updateZoomShiftControls];
}

- (IBAction)shiftChartLeftRight:(id)sender
{
	int sel = [sender selectedSegment];
	switch (sel)
	{
		case 0:
			[chartView shiftLeft:sender];
			break;
		case 1:
			[chartView shiftRight:sender];
	}
	[self _updateZoomShiftControls];
}

- (IBAction)onlineHelp:(id)sender
{
	int topic = [sender tag];
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	[[NSHelpManager sharedHelpManager] openHelpAnchor:[helpAnchors objectAtIndex:topic] inBook:locBookName];
}

- (IBAction)goToWebsite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:WEBSITE_URL,
		[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
}

- (IBAction)goToGGroup:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GGROUP_URL]];
}

- (IBAction)goToEmeLodge:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:EME_URL,
		[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
}

- (IBAction)dismissDiagnosticsSheet:(id)sender
{
	[diagnosticsSheet orderOut:sender];
	[NSApp endSheet:diagnosticsSheet returnCode:0];
}

- (IBAction)showRegistrationPane:(id)sender
{
	[self showPreferenceWindow:sender];
	[preferenceController selectPaneWithIdentifier:@"pane5"];
}

- (IBAction)showPreferenceWindow:(id)sender
{
	if (!preferenceController)
	{
		PreferenceController *controller = [[PreferenceController alloc] init];
		[self setPreferencesController:controller];
		[controller release];
	}
	// we act as delegate ourselves
	[preferenceController setDelegate:self];
	[preferenceController showWindow:self];
	[[preferenceController window] makeKeyAndOrderFront:self];
	// Activate app if not active
	if (![NSApp isActive])
	{
		[NSApp activateIgnoringOtherApps:YES];
	}
}

- (IBAction)showAboutPanel:(id)sender
{
	if (!aboutController)
	{
		aboutController = [[AboutController alloc] init];
	}
	[aboutController showWindow:self];
	[[aboutController window] makeKeyAndOrderFront:sender];
}

- (IBAction)showBatteryRecallAssistant:(id)sender
{
	if (!recallController)
	{
		recallController = [[RecallController alloc] init];
	}
	[recallController setAppController:self];
	[recallController showWindow:self];
	[[recallController window] makeKeyAndOrderFront:sender];
}

- (IBAction)openLogInConsole:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[BatteryLogger logPath] withApplication:@"Console"];
}

- (IBAction)stopResumeMonitoring:(id)sender
{
	/**
	*	Policy on how to handle Stop / Resume
	 *
	 *	When monitoring is NO, the timer will be invalidated. It will be restored
	 *	when monitoring becomes YES again.
	 *
	 *	Since passive notification via SystemConfiguration is boring to register/unregister,
	 *	when monitoring is NO, we'll simply ignore the notifications.
	 */
	
	NSString *msg;
	BatteryManager *mgr = [[managerController selectedObjects] objectAtIndex:0];
	if ([mgr isMonitoring])
	{
		msg = NSLocalizedString(@"=== Monitoring stopped ===", @"=== Monitoring stopped ===");
		
		[self notify:MBLGrowlMonitoringStoppedNotification
			   title:MBLGrowlMonitoringStoppedNotification
			 details:nil];
		
		[mgr stopMonitoring];
	}
	else
	{
		msg = NSLocalizedString(@"=== Monitoring resumed ===", @"=== Monitoring resumed ===");
		
		[self notify:MBLGrowlMonitoringStartedNotification
			   title:MBLGrowlMonitoringStartedNotification
			 details:nil];
		
		[mgr startMonitoring];
	}
	[self appendToLog:msg];
	// Update toolbar item
	[self validateToolbarItem:stopResumeItem];
}

- (IBAction)clearLog:(id)sender
{
	[logController setContent:[[NSMutableArray alloc] init]];
}

- (IBAction)resetOnBatteryTimer:(id)sender
{
	[battery resetTimeOnBattery];
}

- (IBAction)showSession:(id)sender
{
	[chartView zoomToFit:sender];
	[self _updateZoomShiftControls];
}

- (IBAction)showCurrentSession:(id)sender
{
	[sessionsController setSelectionIndex:0];
	[self showSession:sender];
}

- (IBAction)saveSessions:(id)sender
{
	// Flush changes
	[sessionsController commitEditing];
	// Get current sessions
	NSMutableArray *sessions = [sessionsController content];
	// Save to disk
	[MonitoringSession saveToFileSessions:sessions
							   forBattery:[batteryManager serviceUID]
								  atIndex:[batteryManager index]];
}

- (IBAction)removeSession:(id)sender
{
	// Flush changes
	[sessionsController commitEditing];
	// Get current sessions
	MonitoringSession *session = [[sessionsController selectedObjects] objectAtIndex:0];
	// Delete from disk
	[MonitoringSession deleteFromDiskSession:session
								  forBattery:[batteryManager serviceUID]
									 atIndex:[batteryManager index]];
	// Remove from arraycontroller
	[sessionsController remove:sender];

	// Rearrange objects
	[sessionsController rearrangeObjects];
}

- (IBAction)removeAllSavedSessions:(id)sender
{
	if (NSOKButton == NSRunCriticalAlertPanel(NSLocalizedString(@"Delete saved sessions?", @"Delete saved sessions?"),
											  NSLocalizedString(@"This action cannot be undone.", @"This action cannot be undone."),
											  NSLocalizedString(@"OK", @"OK"),
											  NSLocalizedString(@"Cancel", @"Cancel"),
											  nil))
	{
		// Flush changes
		[sessionsController commitEditing];

		NSArray *arr = [sessionsController arrangedObjects];
		int i = 0;
		while (i < [arr count])
		{
			id elem = [[arr objectAtIndex:i] retain];
			
			if ([elem isActive])
			{
				i++;
			}
			else
			{
				[MonitoringSession deleteFromDiskSession:elem
											  forBattery:[batteryManager serviceUID]
												 atIndex:[batteryManager index]];
				// Remove from arraycontroller
				[sessionsController removeObject:elem];
				
				// Remove from manager's sessions
				[[batteryManager sessions] removeObject:elem];
			}
			
			[elem release];
		}		
		// Rearrange objects
		[sessionsController rearrangeObjects];
	}
}

- (IBAction)removeZeroDurationSessions:(id)sender
{
	if (NSOKButton == NSRunCriticalAlertPanel(NSLocalizedString(@"Delete sessions?", @"Delete sessions?"),
											  NSLocalizedString(@"This action cannot be undone.", @"This action cannot be undone."),
											  NSLocalizedString(@"OK", @"OK"),
											  NSLocalizedString(@"Cancel", @"Cancel"),
											  nil))
	{
		// Flush changes
		[sessionsController commitEditing];
		
		NSArray *arr = [sessionsController arrangedObjects];
		int i = 0;
		while (i < [arr count])
		{
			id elem = [[arr objectAtIndex:i] retain];

			if ([elem isActive] ||
				([elem duration] > 0))
			{
				i++;
			}
			else
			{
				// Delete from disk
				[MonitoringSession deleteFromDiskSession:elem
											  forBattery:[batteryManager serviceUID]
												 atIndex:[batteryManager index]];
				// Remove from arraycontroller
				[sessionsController removeObject:elem];
				
				// Remove from manager's sessions
				[[batteryManager sessions] removeObject:elem];
			}
			[elem release];
		}		
		// Rearrange objects
		[sessionsController rearrangeObjects];
	}
}

- (IBAction)toggleSessionsBrowser:(id)sender
{
	if ([sessionsDrawer state] == NSDrawerClosedState)
	{
		NSScreen *myScreen = [window screen];
		if (myScreen)
		{
			NSRect visibleFrame = [myScreen visibleFrame];
			NSRect windowFrame = [window frame];
			
			float drawerHeight = [sessionsDrawer contentSize].height;
			if (NSMinY(windowFrame) - NSMinY(visibleFrame) < drawerHeight &&
				NSMaxY(visibleFrame) - NSMaxY(windowFrame) < drawerHeight)
			{
				windowFrame.origin.y += drawerHeight - NSMinY(windowFrame) + NSMinY(visibleFrame);
				if (NSMaxY(windowFrame) > NSMaxY(visibleFrame))
				{
					windowFrame.size.height += NSMaxY(visibleFrame) - NSMaxY(windowFrame);
				}
				
				[window setFrame:windowFrame
						 display:YES
						 animate:YES];
				
				[sessionsDrawer performSelector:@selector(toggle:)
									 withObject:sender
									 afterDelay:[window animationResizeTime:windowFrame]];
				return;
			}
		}
	}
	[sessionsDrawer toggle:sender];
}

- (IBAction)openEnergySaver:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/EnergySaver.prefPane"];
}

- (IBAction)newSession:(id)sender
{
	// Flush pending changes
	[sessionsController commitEditing];
	
	// Unload sessions
	[self unloadSessions];
	
	// Get current sessions
	[batteryManager startNewSession];
	
	// Reload sessions
	[sessionsController setContent:[NSMutableArray arrayWithArray:[batteryManager sessions]]];
	
	// Force UI update
	[sessionsController rearrangeObjects];
}

- (IBAction)inspectChart:(id)sender
{
	// Show chart view (if not visible)
	[tabView selectTabViewItemAtIndex:0];
	// Update view selector
	[viewSwitcher setSelectedSegment:0];
	// Update chart controls
	[self _updateZoomShiftControls];
	[self _updateViewChooserMenuItems];
	// Force a selection in chart view
	[chartView forceSelection:sender];
	// Show the chart inspector
	[balloon orderFront:sender];
}

- (IBAction)diagnoseBattery:(id)sender
{
	[comparationAgent prepareDiagnostics:sender];
	[NSApp beginSheet:diagnosticsSheet
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:nil
		  contextInfo:NULL];
}

- (IBAction)changeStatusItemMode:(id)sender
{
	int statusItemMode = [sender tag];
	
	[statusItem setVisualizationMode:statusItemMode];
	
	// Store the visualization mode
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:statusItemMode]
											  forKey:MBLStatusItemModeKey];
	// Unmark all items
	[self deselectStatusModeItems];
	
	// Mark selected item
	[sender setState:NSOnState];
}

- (IBAction)changeStatusItemTimeDisplay:(id)sender
{
	BOOL hideTimeWhenPossible = !([sender state] == NSOnState);
	[sender setState:hideTimeWhenPossible ? NSOnState : NSOffState];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hideTimeWhenPossible]
											  forKey:MBLStatusItemHideTimeWhenPossibleKey];
	
	[statusItem setHidesTimeWhenPossible:hideTimeWhenPossible];
}

/* Data import/export */

- (IBAction)exportDataToCSV:(id)sender
{
	NSSavePanel *sPanel = [NSSavePanel savePanel];
	[sPanel setTitle:NSLocalizedString(@"Export", @"Export")];
	[sPanel setRequiredFileType:@"csv"];
	[sPanel setCanSelectHiddenExtension:YES];
	if ([sPanel runModalForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:MBLExportFolderKey]
								file:NSLocalizedString(@"Session", @"Session")] == NSFileHandlingPanelOKButton)
	{
		NSString *filePath =  [sPanel filename];
		[sessionsController commitEditing];
		NSArray *arr = (NSArray *)[sessionsController arrangedObjects];
		int sel = [sessionsController selectionIndex];
		NSString *CSVStream = [[[arr objectAtIndex:sel] events] CSVString];
		
		// Here we deal with a Tiger-only API. Test for compliance.
		BOOL success = NO;
		if ([CSVStream respondsToSelector:@selector(writeToFile:atomically:encoding:error:)])
		{
			success = [CSVStream writeToFile:filePath
								  atomically:YES
									encoding:NSUTF8StringEncoding
									   error:NULL];
		}
		else
		{
			success = [CSVStream writeToFile:filePath
								  atomically:YES];
		}
		
		if (!success)
		{
			NSRunCriticalAlertPanel(NSLocalizedString(@"Error writing to file",@"Error writing to file"),
									[NSString stringWithFormat:NSLocalizedString(@"Could not write to file %@",@"Could not write to file %@"),
										filePath],
									NSLocalizedString(@"OK",@"OK"),
									nil,
									nil);
		}
		
		/* Store export directory for later */
		[[NSUserDefaults standardUserDefaults] setObject:[sPanel directory]
												  forKey:MBLExportFolderKey];
	}
}

- (IBAction)exportDataToCSVMSExcel:(id)sender
{
	NSSavePanel *sPanel = [NSSavePanel savePanel];
	[sPanel setTitle:NSLocalizedString(@"Export", @"Export")];
	[sPanel setRequiredFileType:@"csv"];
	[sPanel setCanSelectHiddenExtension:YES];
	if ([sPanel runModalForDirectory:[[NSUserDefaults standardUserDefaults] objectForKey:MBLExportFolderKey]
								file:NSLocalizedString(@"Session", @"Session")] == NSFileHandlingPanelOKButton)
	{
		NSString *filePath =  [sPanel filename];
		[sessionsController commitEditing];
		NSArray *arr = (NSArray *)[sessionsController arrangedObjects];
		int sel = [sessionsController selectionIndex];
		NSString *CSVStream = [[[arr objectAtIndex:sel] events] CSVStringMSExcel];
		
		// Here we deal with a Tiger-only API. Test for compliance.
		BOOL success = NO;
		if ([CSVStream respondsToSelector:@selector(writeToFile:atomically:encoding:error:)])
		{
			success = [CSVStream writeToFile:filePath
								  atomically:YES
									encoding:NSUTF8StringEncoding
									   error:NULL];
		}
		else
		{
			success = [CSVStream writeToFile:filePath
								  atomically:YES];
		}
		
		if (!success)
		{
			NSRunCriticalAlertPanel(NSLocalizedString(@"Error writing to file",@"Error writing to file"),
									[NSString stringWithFormat:NSLocalizedString(@"Could not write to file %@",@"Could not write to file %@"),
										filePath],
									NSLocalizedString(@"OK",@"OK"),
									nil,
									nil);
		}
		
		/* Store export directory for later */
		[[NSUserDefaults standardUserDefaults] setObject:[sPanel directory]
												  forKey:MBLExportFolderKey];
	}
}

#pragma mark === Remote Manager ===

- (void)attachStartupRemoteConnections
{
	NSArray *startupConnectionAddresses = [RemoteConnectionController startupConnectionAddresses];
	int i;
	for (i = 0; i < [startupConnectionAddresses count]; i++)
	{
		[self connectToAddress:[[startupConnectionAddresses objectAtIndex:i] objectForKey:@"address"]];
	}
}

- (void)removeManager:(BatteryManager *)mgr
{
	[mgr stopMonitoring];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLSaveSessionOnQuitKey] boolValue])
	{
		if ([mgr serviceUID])
		{
			// Save sessions
			NSArray *sess = [mgr sessions];
			[MonitoringSession saveToFileSessions:sess forBattery:[mgr serviceUID] atIndex:[mgr index]];
		}
	}
	if ([mgr serviceUID])
	{
		[loadedSessions removeObjectForKey:[mgr serviceUID]];
	}
	[managerController removeObject:mgr];
	// Just to be sure
	[managersList reloadData];
}

- (BOOL)registerRemoteService:(BatteryManager *)remote
{
	if (!remoteServices)
	{
		remoteServices = [[NSMutableDictionary alloc] init];
	}
	if (![self isRegisteredRemoteService:remote])
	{
		[remoteServices setObject:remote
						   forKey:[[remote name] objectAtIndex:0]];
		return YES;
	}
	return NO;
}

- (void)unregisterRemoteService:(BatteryManager *)remote
{
	[remoteServices removeObjectForKey:[[remote name] objectAtIndex:0]];
}

- (BOOL)isRegisteredRemoteService:(BatteryManager *)remote
{
	return [remoteServices objectForKey:[[remote name] objectAtIndex:0]] != nil;
}

@end

@implementation AppController (SharedBatteryDataArchive)

#pragma mark === Archive Actions ===

- (IBAction)archiveEntryPage:(id)sender
{
	[SharedArchive archiveEntryForBattery:[batteryManager serviceUID]];
}

@end

@implementation AppController (RemoteMonitoring)

- (IBAction)disconnectManager:(id)sender
{
	id mgr = [[managerController selectedObjects] objectAtIndex:0];
	if ([self isRegisteredRemoteService:mgr])
	{
		[self unregisterRemoteService:mgr];
		[self removeManager:mgr];
	}
}

- (IBAction)disconnectAllManagers:(id)sender
{
	NSEnumerator *mgrEnum = [[managerController	content] objectEnumerator];
	id mgr;
	while (mgr = [mgrEnum nextObject])
	{
		if ([self isRegisteredRemoteService:mgr])
		{
			[self unregisterRemoteService:mgr];
			[self removeManager:mgr];
		}
	}
}

- (IBAction)connectManager:(id)sender
{
	if (remoteConnectionController == nil)
	{
		remoteConnectionController = [[RemoteConnectionController alloc] init];
		[remoteConnectionController setOwner:self];
	}
	[remoteConnectionController showWindow:sender];
	[[remoteConnectionController window] makeKeyAndOrderFront:sender];
}

- (void)connectToAddress:(NSString *)address
{
	RemoteBatteryManager *remote = [[RemoteBatteryManager alloc] initWithRemoteAddress:address
																				 index:0];
	if ([self registerRemoteService:remote])
	{
		[managerController addObject:remote];
		[self appendToLog:[NSString stringWithFormat:NSLocalizedString(@"+++ Connecting remote battery at address %@ +++", @"+++ Connecting remote battery at address %@ +++"),
			address]];
	}
	[remote release];
}

@end

@implementation AppController (GrowlApplicationBridgeDelegate_InformalProtocol)


- (NSDictionary *) registrationDictionaryForGrowl
{
	return dictionaryForGrowl;
}

- (NSString *) applicationNameForGrowl
{
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
}

- (NSData *) applicationIconDataForGrowl
{
	return [NSData dataWithContentsOfFile:
		[[NSBundle bundleForClass:[self class]] pathForResource:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey] ofType:@"icns"]];
}

@end

@implementation AppController (NSApplicationDelegate)

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	if (![window isVisible])
	{
		[window makeKeyAndOrderFront:nil];
	}
	return YES;
}

@end

@implementation AppController (NSApplicationNotifications)

- (void) applicationDidFinishLaunching:(NSNotification *) notif
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	/* Launch Migration Agent if needed */
	if (![[defaults objectForKey:MBLDidPerformMigrationKey] boolValue])
	{
		if ([MigrationAgent hasJobToDo])
		{
			NSString *migrationAgentPath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Migration Agent" ofType:@"app"]] executablePath];
			
			NSTask *migrationAgentTask = [[NSTask alloc] init];
			
			[migrationAgentTask setLaunchPath:migrationAgentPath];
			[migrationAgentTask setArguments:[NSArray arrayWithObject:@""]];
			[migrationAgentTask launch];
			[migrationAgentTask waitUntilExit];
			
			[migrationAgentTask release];
			[NSApp activateIgnoringOtherApps:YES];
		}
		[defaults setObject:[NSNumber numberWithBool:YES]
					 forKey:MBLDidPerformMigrationKey];
		[defaults synchronize];
	}
	
	NSString *msg = NSLocalizedString(@"=== Application started ===", @"=== Application started ===");
	[self appendToLog:msg];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryPropertiesChanged:)
												 name:MBLBatteryPropertiesChangedNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryPropertiesChanged:)
												 name:MBLBatteryManagerPropertiesChangedNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryPropertiesChanged:)
												 name:MBLBatteryManagerRemoteConnectionErrorNotification
											   object:nil];
	
	//[self _attachDefaultBatteryManagers];
	
	// Create and populate battery managers pool
	localBatteries = [LocalBatteryManager installedBatteries];
	batteryManagers = [[NSMutableArray alloc] init];	
	int i;
	int lastManagerIndex = 0;

	id lastManager = [defaults objectForKey:MBLLastLocalBatteryIndexKey];
	if (lastManager != nil)
	{
		lastManagerIndex = [lastManager intValue];
	}
	
	for (i = 0; i < localBatteries; i++)
	{
		LocalBatteryManager *mgr = [[LocalBatteryManager alloc] initWithIndex:i];
		[batteryManagers addObject:mgr];
		if (i == lastManagerIndex &&
			!battery)
		{
			// Assign the battery
			battery = [mgr battery];
			
			charge = [battery charge];
			plugged = [battery isPlugged];
			charging = [battery isCharging];
			maxCapacity = [battery maxCapacity];			
		}
				
		if (i == lastManagerIndex &&
			!batteryManager)
		{
			batteryManager = mgr;
		}
		[mgr release];
	}

	if ([[defaults objectForKey:MBLDebugModeKey] boolValue])
	{
		// Append a DemoBatteryManager too...
		DemoBatteryManager *mgr = [[DemoBatteryManager alloc] init];
		[batteryManagers addObject:mgr];
		if (!battery)
		{
			// Assign to first battery
			battery = [mgr battery];
			
			charge = [battery charge];
			plugged = [battery isPlugged];
			charging = [battery isCharging];
			maxCapacity = [battery maxCapacity];
		}
		
		if (!batteryManager)
		{
			batteryManager = mgr;
		}
		[mgr release];		
	}
		
	// Put inside the arraycontroller
	[managerController setContent:batteryManagers];

	// Update manager list selection
	[managerController setSelectionIndex:lastManagerIndex];
		
	// Load previous sessions
	[NSThread detachNewThreadSelector:@selector(loadSessions:)
							 toTarget:self
						   withObject:batteryManager];
	[sessionsController setContent:[NSMutableArray arrayWithArray:[batteryManager sessions]]];
	
	// Load past snapshots from disk
	[self setSnapshots:[BatterySnapshots snapshotsForBattery:[batteryManager serviceUID] atIndex:[batteryManager index]]];
	
	// Fill the snapshots array controller
	[snapshotsController setContent:[snapshots shots]];

	// Update battery snapshots
	[self updateSnapshots];
	
	if ([[defaults objectForKey:MBLLookForSharedDataKey] boolValue])
	{
		// Launch remote monitoring service browser
		serviceBrowser = [[NSNetServiceBrowser alloc] init];
		[serviceBrowser setDelegate:self];
		[serviceBrowser searchForServicesOfType:@"_mbl-battd._tcp." inDomain:@""];
	}
	
	//[[[sessionsController content] objectAtIndex:0] addEvent:[[[WakeUpEvent alloc] init] autorelease]];
	
	// Send own battery data
	if ([[defaults objectForKey:MBLSendOwnDataKey] boolValue])
	{
		[comparationAgent shareBatteryData:nil];
	}
	// Get shared battery data
	if ([[defaults objectForKey:MBLRetrieveDataKey] boolValue])
	{
		[comparationAgent performSelector:@selector(getSharedBatteryData:)
							   withObject:nil
							   afterDelay:5.0];
	}
	
	/* setting custom icon if needed */
	if ([[defaults objectForKey:MBLDisplayCustomIconKey] boolValue])
	{
		[self _updateDockIcon];
	}
	
	/* showing menu item */
	displayStatusItem = [[defaults objectForKey:MBLDisplayStatusItemKey] boolValue];
	if (displayStatusItem)
	{
		[self activateStatusMenu];
		if (![[[[NSBundle mainBundle] infoDictionary] valueForKey:LSUIElementKey] boolValue])
		{
			// Remove unnecessary status menu items
			[self removeRedundantStatusMenuItems];
		}
		else
		{
			// Prevent the window from showing automatically
			[window orderOut:nil];
		}
	}

	if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLShowDesktopBatteryKey] boolValue])
	{
		[self showDesktopBatteryWindow];
	}

	/* registering for notifications of interest */
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:NSTableViewSelectionDidChangeNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:NSTableViewSelectionIsChangingNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:MBLTableViewMouseExitedNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:MBLAdvertiseServiceChangedNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:MBLShareOwnDataChangedNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleNotification:)
												 name:MBLLookForSharedDataChangedNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleDisplayCustomIconChange:)
												 name:MBLDisplayCustomIconChangedNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleDisplayStatusItemChange:)
												 name:MBLDisplayStatusItemChangedNotification
											   object:nil];
	
	/* registering for NSWorkspace notifications of Wake up / Sleep / Power off events */
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(handleSleepWakeShutdown:)
															   name:NSWorkspaceWillSleepNotification
															 object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(handleSleepWakeShutdown:)
															   name:NSWorkspaceDidWakeNotification
															 object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
														   selector:@selector(handleSleepWakeShutdown:)
															   name:NSWorkspaceWillPowerOffNotification
															 object:nil];	
	
	// If the application is not registered, show the reminder
	// This is called after hiding the window to prevent the
	// reminder from being accidentally hidden as well
	if (![self isRegistered]
		&& [self _shouldShowRegistrationReminder]
		)
	{
		[self showRegistrationReminder];
	}
	
	// Bind the chart view events to the current selection of sessionsController's events
	[chartView bind:@"events"
		   toObject:sessionsController
		withKeyPath:@"selection.events"
			options:nil];

	// Bind the status view battery to the current selection of batteryController
	[statusView bind:@"battery"
		   toObject:batteryController
		withKeyPath:@"selection.self"
			options:nil];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLStartMonitoringAtLaunchKey] boolValue])
	{
		// Start monitoring
	}
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLShareOwnDataKey] boolValue])
	{
		[MBLSharingService startWorkerThreadMaster:self];
	}
	
	// Attach favorite remote batteries that must be connected at startup
	[self attachStartupRemoteConnections];
}

- (void) applicationWillTerminate:(NSNotification *) notif
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// Save sessions on quit if requested
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:MBLSaveSessionOnQuitKey] boolValue])
	{
		[self saveSessions:nil];
	}
	
	batteryManagers = [managerController content];
	/*
	int i;
	for (i = 0; i < [batteryManagers count]; i++)
	{
		BatteryManager *mgr = [batteryManagers objectAtIndex:0];
	}
	 */
	
	// Save snapshots
	[snapshots saveToFileForBattery:[batteryManager serviceUID] atIndex:[batteryManager index]];

	[sidebarSplitView saveState:YES];
	
	[self removeStatusMenu];
	[NSApp setApplicationIconImage:[NSImage imageNamed:@"MiniBatteryLogger"]];
}

@end

@implementation AppController (Private)

- (NSData *)_notificationIconData
{
	return [[NSImage dockIconForBattery:[batteryManager battery]] TIFFRepresentation];
}

- (void)_updateDockIcon
{
	[NSApp setApplicationIconImage:[NSImage dockIconForBattery:battery]];
}

- (void)_updateViewChooserMenuItems
{
	int tabSelection = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	[chartViewItem setState:(tabSelection == 0) ? NSOnState : NSOffState]; 
	[statsViewItem setState:(tabSelection == 1) ? NSOnState : NSOffState]; 
	[compViewItem setState:(tabSelection == 2) ? NSOnState : NSOffState]; 
	[logViewItem setState:(tabSelection == 3) ? NSOnState : NSOffState]; 	
}
- (void)_updateZoomShiftControls
{
	if (zoomControl)
	{
		[zoomControl setEnabled:[chartView canZoomIn] forSegment:0];
		[zoomControl setEnabled:[chartView canZoomOut] forSegment:2];
		[zoomControl setEnabled:([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 0)];
	}
	if (shiftControl)
	{
		[shiftControl setEnabled:[chartView canShiftLeft] forSegment:0];
		[shiftControl setEnabled:[chartView canShiftRight] forSegment:1];
		[shiftControl setEnabled:([tabView indexOfTabViewItem:[tabView selectedTabViewItem]] == 0)];
	}
}

- (void)sheetDidEnd:(NSWindow *)sheet
		 returnCode:(int)retCode
		contextInfo:(void *)cInfo
{
	
}

- (void)updateSnapshots
{
	id lastSnapshot = nil;

	if ([snapshots count] > 0)
	{
		lastSnapshot = [[snapshots shotAtIndex:[snapshots count] - 1] battery];
		
		if ([lastSnapshot maxCapacity] != [battery maxCapacity] ||
			[lastSnapshot cycleCount] != [battery cycleCount])
		{
			// Adding snapshot
			[self addSnapshot:nil];
			
			// Issue a Growl notification when snapshots are automatically grabbed
			[self notify:MBLGrowlBatteryLowNotification
				   title:MBLGrowlSnapshotGrabbedNotification
				 details: NSLocalizedString(@"Cycle count or maximum capacity changed. Adding a snapshot", @"Cycle count or maximum capacity changed. Adding a snapshot")];
		}
	}
	else
	{
		// Create a new BatterySnapshots object and set snapshotsController's contents to its shots
		[self setSnapshots:[BatterySnapshots snapshots]];
		
		[snapshots addShot:battery];
		[snapshotsController setContent:[snapshots shots]];
	}
	[snapshotsController rearrangeObjects];
}

- (NSArray *)batteryPatternsArray
{
	NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:localBatteries];
	int i;
	for (i = 0; i < localBatteries; i++)
	{
		[tempArr insertObject:[NSString stringWithFormat:BATTERY_PATTERN, i] atIndex:i];
	}
	return [[tempArr copy] autorelease];
}

- (BOOL)_shouldShowRegistrationReminder
{
	BOOL expired = NO;
	NSString *cacheName = [[NSString alloc] initWithData:[NSData dataWithBase64EncodedString:MBLCacheName]
												encoding:NSUTF8StringEncoding];
	
	NSString *markerFilePath = [[[[@"~" stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:cacheName] stringByExpandingTildeInPath];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:markerFilePath])
	{
		NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:markerFilePath traverseLink:YES];		
		if (fileAttributes != nil)
		{
			NSDate *fileModDate;
			if (fileModDate = [fileAttributes objectForKey:NSFileModificationDate])
			{
				expired = (fabs([fileModDate timeIntervalSinceNow]) > EVALUATION_PERIOD_INTERVAL);
			}
		}
	}
	else
	{
		[fileManager createFileAtPath:markerFilePath
							 contents:[cacheName dataUsingEncoding:NSUTF8StringEncoding]
						   attributes:nil];
	}
	[cacheName release];
	return expired;
}

- (void) _registerForPowerChanges:(id)source
{
#pragma unused (source)
	// This is a disguised method that verifies if somebody has tampered with
	// the executable binary and if this is true, quits the application.
	
	NSString *theAppSignature = [[[NSFileManager defaultManager] contentsAtPath:[[NSBundle mainBundle] executablePath]] md5HashAsString];
	
	NSString *canonicalSignature = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"toolow.tiff"]];
	
	if (![theAppSignature isEqualToString:canonicalSignature])
	{
		NSLog(@"A fatal error occurred");
		[NSApp terminate:nil];
	}
}

- (BOOL) needsMigration
{
	BOOL needs = YES;
	
	return needs;
}

- (void)localizeUIElements
{
	[batteryStatusToggler setToolTip:NSLocalizedString(@"Hide Battery Status", @"Hide Battery Status")];
}

#pragma mark === Private setters ===

- (void)setSnapshots:(BatterySnapshots *)s
{
	[s retain];
	[snapshots release];
	snapshots = s;
}

- (void)setPreferencesController:(AMPreferenceWindowController *)ctl
{
	[ctl retain];
	[preferenceController release];
	preferenceController = ctl;
}

#pragma mark === Registration handling ===

- (void)showRegistrationReminder
{
	if ([NSApp isHidden] ||
		![window isVisible])
	{
		// The app has been launched in hidden state, like a login item
		
		// Activate the app
		[NSApp activateIgnoringOtherApps:YES];
	}
	[self showRegistrationPane:nil];
}

- (BOOL)registerToUser:(NSString *)user key:(NSString *)key
{	
	if (![user isEqual:@""] &&
		![key isEqual:@""] &&
		[key length] >= [MBLLicense minKeyLength])
	{
		MBLLicense *license = [MBLLicense licenseForUsername:user key:key];
		if ([license isValid])
		{
			if ([[license expirationDate] compare:[NSDate date]] == NSOrderedDescending)
			{
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:user forKey:MBLDefaultsRegisteredUserKey];
				[defaults setObject:key forKey:MBLDefaultsRegistrationKeyKey];
				[defaults synchronize];

				[[NSSound soundNamed:@"Magic Bell"] play];
				
				if (preferenceController &&
					[[preferenceController window] isVisible])
				{
					[[[preferenceController prefPanes] objectForKey:@"pane5"] showRegistrationInfo];
				}
				
				return true;
			}
			else
			{
				NSRunAlertPanel(NSLocalizedString(@"License expired", @"License expired"),
								NSLocalizedString(@"The license you entered was valid, but has already expired", @"The license you entered was valid, but has already expired"),
								NSLocalizedString(@"OK", @"OK"),
								nil,
								nil);
			}
		}
	}	
	return false;
}

- (void)deRegister
{
	// Why would you deregister an App? Mmh...
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:MBLDefaultsRegisteredUserKey];
	[defaults removeObjectForKey:MBLDefaultsRegistrationKeyKey];
}

#pragma mark === GrowlApplicationBridgeDelegate Bridge methods ===

- (void)notify:(NSString *)type
		 title:(NSString *)title
	   details:(NSString *)details
{
	switch ([[[NSUserDefaults standardUserDefaults] objectForKey:MBLAlertModeKey] intValue])
	{
		case MBLAlertModeNone:
			break;
		case MBLAlertModeSpeech:
			if (!speechSynth)
			{
				speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:nil];
			}
			[speechSynth startSpeakingString:details];
			break;
		case MBLAlertModeGrowl:
		default:
			[GrowlApplicationBridge notifyWithTitle:title
										description:details
								   notificationName:type
										   iconData:[self _notificationIconData]
										   priority:0
										   isSticky:NO
									   clickContext:nil];
	}
}

- (void)appendToLog:(NSString *)msg
{
	// Create line with timestamp
	NSString *line = [[[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S "] stringByAppendingString:msg];
	// Append to log pane
	[logController addObject:line];
	if (YES) // Replace with a user preference
	{
		// Append to log file
		[logger logText:line];
	}
}

- (void)initializeToolbar
{
    toolbar = [[NSToolbar alloc] initWithIdentifier:MBLMainToolbarIdentifier];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setDelegate:self];
    [window setToolbar:toolbar];
    [toolbar release];
}

#pragma mark === Status menu ===

- (void)activateStatusMenu
{
	statusItem = [[MBLStatusItem alloc] initWithController:batteryController];
	[statusItem setMenu:statusMenu];
	
	// Set the state of the Hide Time When Possible menu item
	[hideTimeItem setState:[statusItem hidesTimeWhenPossible] ? NSOnState : NSOffState];
	
	/* Mark the current visualization mode */
	[self markStatusModeItemWithTag:[statusItem visualizationMode]];
}

- (void)deselectStatusModeItems
{
	NSEnumerator *itemEnumerator = [statusMenuItems objectEnumerator];
	NSMenuItem *item;
	while (item = (NSMenuItem *)[itemEnumerator nextObject])
	{
		[item setState:NSOffState];
	}
}

- (void)markStatusModeItemWithTag:(int)tag
{
	/* Unmark all */
	[self deselectStatusModeItems];

	NSEnumerator *itemEnumerator = [statusMenuItems objectEnumerator];
	NSMenuItem *item;
	while (item = (NSMenuItem *)[itemEnumerator nextObject])
	{
		if ([item tag] == tag)
		{
			[item setState:NSOnState];
		}
	}
}

- (void)removeStatusMenu
{
    [statusItem remove];
	statusItem = nil;
}

- (void)removeRedundantStatusMenuItems
{
	NSEnumerator *itemEnumerator = [auxStatusMenuItems objectEnumerator];
	NSMenuItem *item;
	while (item = (NSMenuItem *)[itemEnumerator nextObject])
	{
		[statusMenu removeItem:item];
	}
}

- (void)chargingChanged
{
	if (charging ^ [battery isCharging])
	{
		NSString *msg;
		if ([battery isCharging])
		{
			msg = NSLocalizedString(@"+++ Battery is now charging +++", @"+++ Battery is now charging +++");
			[self notify:MBLGrowlChargeStartedNotification
				   title:MBLGrowlChargeStartedNotification
				 details:nil];
		}
		else if (plugged)
		{
			msg = NSLocalizedString(@"+++ Battery has been charged +++", @"+++ Battery has been charged +++");
			[self notify:MBLGrowlChargeStoppedNotification
				   title:MBLGrowlChargeStoppedNotification
				 details:nil];			
		}
		else // unplugged
		{
			msg = NSLocalizedString(@"+++ Battery charge interrupted +++", @"+++ Battery charge interrupted +++");
			[self notify:MBLGrowlChargeStoppedNotification
				   title:MBLGrowlChargeStoppedNotification
				 details:nil];
		}
		[self appendToLog:msg];
	}
	charging = [battery isCharging];
}

- (void)pluggedChanged
{
	if (plugged ^ [battery isPlugged])
	{
		NSString *msg = [battery isPlugged] ?
			NSLocalizedString(@"+++ Switching to AC Power +++", @"+++ Switching to AC Power +++") :
			NSLocalizedString(@"--- Switching to Battery Power ---", @"--- Switching to Battery Power ---");
		
		[self notify:MBLGrowlPowerSourceChangedNotification
			   title:MBLGrowlPowerSourceChangedNotification
			 details:[battery isPlugged] ? NSLocalizedString(@"Switching to AC Power", @"Switching to AC Power") : NSLocalizedString(@"Switching to Battery Power", @"Switching to Battery Power")];
		
		[self appendToLog:msg];
		
		// Auto save sessions if requested
		if ([[[NSUserDefaults standardUserDefaults] valueForKey:MBLAutoSaveSessionsKey] boolValue])
		{
			[self saveSessions:nil];
		}	
	}
	plugged = [battery isPlugged];
}

- (void)chargeChanged
{
	if ([battery charge] < charge && // Notify only when depleting
		[battery charge] <= [[[NSUserDefaults standardUserDefaults] valueForKey:MBLLowAlertLevelKey] intValue])
	{
		[self notify:MBLGrowlBatteryLowNotification
			   title:MBLGrowlBatteryLowNotification
			 details:[NSString stringWithFormat:NSLocalizedString(@"Current Charge: %d%%", @"Current Charge: %d%%"), [battery charge]]];
	}
	charge = [battery charge];
}

- (void)maxCapacityChanged
{
	int strength = (int)round(100.0 * [battery maxCapacity] / [battery absoluteMaxCapacity]);
	if ([battery maxCapacity] < maxCapacity && // Notify only when depleting
		strength <= [[[NSUserDefaults standardUserDefaults] valueForKey:MBLDyingAlertLevelKey] intValue])
	{
		[self notify:MBLGrowlBatteryExhaustedNotification
			   title:MBLGrowlBatteryExhaustedNotification
			 details:[NSString stringWithFormat:NSLocalizedString(@"The battery has reached the %d%% of its original capacity", @"The battery has reached the %d%% of its original capacity"), strength]];
	}
	maxCapacity = [battery maxCapacity];
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

// We broadcast the willChangeValueForKey: and didChangeValueForKey: for the NSTableView binding to work.

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	// Found Net Service
	
	if (![[aNetService name] isEqualToString:[CPSystemInformation computerName]])
	{
		BonjourBatteryManager *mgr = [[BonjourBatteryManager alloc] initWithService:aNetService index:0];

		if ([self registerRemoteService:mgr])
		{
			[managerController addObject:mgr];
		}
		
		[self notify:MBLGrowlSharingServiceFoundNotification
			   title:MBLGrowlSharingServiceFoundNotification
			 details:[NSString stringWithFormat:NSLocalizedString(@"Added shared battery #%d on %@", @"Added shared battery #%d on %@"),
				 [batteryManager index] + 1, // Use a friendly number
				 [aNetService name]]];

		[mgr release];
		
	}
	else
	{
		//NSLog(@"Can't add myself as a remote service");
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	
	// Service no more available
	id mgr = [remoteServices objectForKey:[aNetService name]];
	if (mgr)
	{
		[self notify:MBLGrowlSharingServiceRemovedNotification
			   title:MBLGrowlSharingServiceRemovedNotification
			 details:[NSString stringWithFormat:NSLocalizedString(@"Shared battery #%d on %@ no longer available", @"Shared battery #%d on %@ no longer available"), [batteryManager index], [aNetService name]]];
		
		[self unregisterRemoteService:mgr];
		[self removeManager:mgr];
	}
}

@end

@implementation AppController (NSNibAwaking)

- (void)awakeFromNib
{
	_AppControllerSharedInstance = self;
	
	[self localizeUIElements];
	
	[[self class] checkDockIcon];
	
	statusMenuItems = [[NSArray alloc] initWithObjects:iconOnlyItem,
		timeItem,
		chargeItem,
		timeChargeItem,
		batteryTimerItem,
		nil];
	
	auxStatusMenuItems = [[NSArray alloc] initWithObjects:auxQuitMenuItem,
		auxHelpMenuItem,
		auxPreferencesMenuItem,
		auxSeparatorMenuItem,
		nil];
		
	loadedSessions = [[NSMutableDictionary alloc] init];
	
	[managersList setUsesGradientSelection:YES];
	[[managersList tableColumnWithIdentifier:@"mgr_name"] setDataCell:[[[MBLBatteryManagerCell alloc] init] autorelease]];

	// Double clicking on the managers list will bring up the inspector pane
	[managersList setTarget:detailsPanel];
	[managersList setDoubleAction:@selector(orderFront:)];
	
	[sidebarSplitView setDividerThickness:1.0];
	[sidebarSplitView restoreState:YES];
	
	// Initialize toolbar
    [self initializeToolbar];

	dictionaryForGrowl = [[NSDictionary dictionaryWithObjectsAndKeys:
		[NSArray arrayWithObjects:
			MBLGrowlChargeStartedNotification,
			MBLGrowlChargeStoppedNotification,
			MBLGrowlBatteryLowNotification,
			MBLGrowlPowerSourceChangedNotification,
			MBLGrowlMonitoringStartedNotification,
			MBLGrowlMonitoringStoppedNotification,
			MBLGrowlBatteryExhaustedNotification,
			MBLGrowlSnapshotGrabbedNotification,
			MBLGrowlBatteryChangedNotification,
			MBLGrowlSharingServiceFoundNotification,
			MBLGrowlSharingServiceRemovedNotification,
			MBLGrowlTestNotification,
			nil],
		GROWL_NOTIFICATIONS_ALL,
		[NSArray arrayWithObjects:
			MBLGrowlChargeStartedNotification,
			MBLGrowlChargeStoppedNotification,
			MBLGrowlBatteryLowNotification,
			MBLGrowlPowerSourceChangedNotification,
			MBLGrowlMonitoringStartedNotification,
			MBLGrowlMonitoringStoppedNotification,
			MBLGrowlBatteryExhaustedNotification,
			MBLGrowlSnapshotGrabbedNotification,
			MBLGrowlBatteryChangedNotification,
			MBLGrowlSharingServiceFoundNotification,
			MBLGrowlSharingServiceRemovedNotification,
			MBLGrowlTestNotification,
			nil],
		GROWL_NOTIFICATIONS_DEFAULT,
		nil] retain];
	
	helpAnchors = [[NSArray arrayWithObjects:
		@"using",		// 0
		@"chartview",	// 1
		@"logview",		// 2
		@"chartcolors",	// 3
		@"export",		// 4
		@"faq",			// 5
		@"register",	// 6
		@"preferences",	// 7
		@"shareddata",	// 8
		@"diagnostics",	// 9
		@"recall",		// 10
		nil] retain];
	
	[GrowlApplicationBridge setGrowlDelegate:self];	
	
	logger = [[BatteryLogger alloc] init];
	[logView setFont:[NSFont fontWithName:@"Monaco"
									 size:10]];	
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:MBLSidebarSizeKey])
	{
		NSRect sidebarRect;
		sidebarRect.origin = NSZeroPoint;
		sidebarRect.size = NSSizeFromString([[NSUserDefaults standardUserDefaults] objectForKey:MBLSidebarSizeKey]);
		[[[sidebarSplitView subviews] objectAtIndex:0] setFrame:sidebarRect];
	}

	// Call the method that verifies the integrity of the binary
	// This avoids some tricks like binhex cracking etc.
	/*
	[NSTimer scheduledTimerWithTimeInterval:600 // check every ten minutes (this seems reasonable)
									 target:self
								   selector:@selector(_registerForPowerChanges:)
								   userInfo:NULL
									repeats:NO];
	 */
	
}

@end

@implementation AppController (NSToolbarDelegate)

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdent
 willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
	/**
	 *	MEMO: when adding a toolbar item target to self, REMEMBER to return YES
	 *	in the method validateToolbarItem:
	 */
	
	NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];
	[toolbarItem autorelease];	
	if ([itemIdent isEqual:MBLSwitchViewToolbarItemIdentifier])
	{
		NSSegmentedControl *segmentedControl = [[AOSegmentedControl alloc] init];
		[segmentedControl setSegmentCount:4];
		[segmentedControl setSelectedSegment:0];
		
		[segmentedControl setImage:[NSImage imageNamed:@"chart"] forSegment:0];
		[segmentedControl setImage:[NSImage imageNamed:@"stats"] forSegment:1];
		[segmentedControl setImage:[NSImage imageNamed:@"comparison"] forSegment:2];
		[segmentedControl setImage:[NSImage imageNamed:@"list"] forSegment:3];
		
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Chart", @"Chart")
								 forSegment:0];
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Statistics", @"Statistics")
								 forSegment:1];
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Comparison", @"Comparison")
								 forSegment:2];
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Log", @"Log")
								 forSegment:3];
		
		[[segmentedControl cell] setTrackingMode:NSSegmentSwitchTrackingSelectOne];
		
		[toolbarItem setMinSize:NSMakeSize(138, 32)];
		[toolbarItem setMaxSize:NSMakeSize(138, 32)];
		
		[toolbarItem setView:segmentedControl];
		
		[toolbarItem setLabel: NSLocalizedString(@"View", @"View")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"View", @"View")];
		[toolbarItem setToolTip:NSLocalizedString(@"View", @"View")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(switchView:)];
		
		[segmentedControl release];
	}
	else if ([itemIdent isEqual:MBLZoomToolbarItemIdentifier])
	{
		NSSegmentedControl *segmentedControl = [[AOSegmentedControl alloc] init];
		[segmentedControl setSegmentCount:3];
		[segmentedControl setSelectedSegment:0];
		
		[segmentedControl setImage:[NSImage imageNamed:@"plus"] forSegment:0];
		[segmentedControl setImage:[NSImage imageNamed:@"fit"] forSegment:1];
		[segmentedControl setImage:[NSImage imageNamed:@"less"] forSegment:2];

		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Zoom in", @"Zoom in")
								 forSegment:0];
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Zoom to fit", @"Zoom to fit")
								 forSegment:1];
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Zoom out", @"Zoom out")
								 forSegment:2];
		
		[[segmentedControl cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
		
		[toolbarItem setMinSize:NSMakeSize(105, 32)];
		[toolbarItem setMaxSize:NSMakeSize(105, 32)];
		
		[toolbarItem setView:segmentedControl];
		
		[toolbarItem setLabel: NSLocalizedString(@"Zoom", @"Zoom")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Zoom", @"Zoom")];
		[toolbarItem setToolTip:NSLocalizedString(@"Zoom", @"Zoom")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(zoomChartInOut:)];
		
		[segmentedControl release];
	}
	else if ([itemIdent isEqual:MBLNavigatorToolbarItemIdentifier])
	{
		NSSegmentedControl *segmentedControl = [[AOSegmentedControl alloc] init];
		[segmentedControl setSegmentCount:2];
		[segmentedControl setSelectedSegment:0];
		
		[segmentedControl setImage:[NSImage imageNamed:@"left"] forSegment:0];
		[segmentedControl setImage:[NSImage imageNamed:@"right"] forSegment:1];

		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Shift left", @"Shift left")
								 forSegment:0];
		[[segmentedControl cell] setToolTip:NSLocalizedString(@"Shift right", @"Shift right")
								 forSegment:1];
		
		[[segmentedControl cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
		
		[toolbarItem setMinSize:NSMakeSize(72, 32)];
		[toolbarItem setMaxSize:NSMakeSize(72, 32)];
		
		[toolbarItem setView:segmentedControl];
		
		[toolbarItem setLabel: NSLocalizedString(@"Shift", @"Shift")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Shift Chart", @"Shift Chart")];
		[toolbarItem setToolTip:NSLocalizedString(@"Shift Chart", @"Shift Chart")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(shiftChartLeftRight:)];
		
		[segmentedControl release];
	}
	else if ([itemIdent isEqual:MBLEnergyPrefsToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"energysaver-preferences"]];
		[toolbarItem setLabel: NSLocalizedString(@"Energy Saver", @"Energy Saver")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Open Energy Saver", @"Open Energy Saver")];
		[toolbarItem setToolTip:NSLocalizedString(@"Open Energy Saver", @"Open Energy Saver")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(openEnergySaver:)];
	}
	else if ([itemIdent isEqual:MBLDiagnosticsToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"battery-doctor"]];
		[toolbarItem setLabel: NSLocalizedString(@"Diagnostics", @"Diagnostics")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Diagnostics", @"Diagnostics")];
		[toolbarItem setToolTip:NSLocalizedString(@"Diagnostics", @"Diagnostics")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(diagnoseBattery:)];
	}
	else if ([itemIdent isEqual:MBLBalloonToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"balloon"]];
		[toolbarItem setLabel: NSLocalizedString(@"Inspect", @"Inspect")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Inspect Session", @"Inspect Session")];
		[toolbarItem setToolTip:NSLocalizedString(@"Inspect Session", @"Inspect Session")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(inspectChart:)];
	}
	else if ([itemIdent isEqual:MBLSessionsToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"sheets"]];
		[toolbarItem setLabel: NSLocalizedString(@"Sessions", @"Sessions")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Sessions Browser", @"Sessions Browser")];
		[toolbarItem setToolTip:NSLocalizedString(@"Sessions Browser", @"Sessions Browser")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(toggleSessionsBrowser:)];		
	}
	else if ([itemIdent isEqual:MBLInspectorToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"inspectorButton"]];
		[toolbarItem setLabel: NSLocalizedString(@"Details", @"Details")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Battery Details", @"Battery Details")];
		[toolbarItem setToolTip:NSLocalizedString(@"Battery Details", @"Battery Details")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(showBatteryDetails:)];		
	}
	else if ([itemIdent isEqual:MBLOpenInConsoleToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"console"]];
		[toolbarItem setLabel: NSLocalizedString(@"Open Log", @"Open Log")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Open Log in Console", @"Open Log in Console")];
		[toolbarItem setToolTip:NSLocalizedString(@"Open Log in Console", @"Open Log in Console")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(openLogInConsole:)];		
	}
	else if ([itemIdent isEqual:MBLStopResumeToolbarItemIdentifier])
	{
		stopResumeItem = toolbarItem;
		BOOL active = YES;
		id obj = [managerController selectedObjects];
		if ([obj count] > 0)
		{
			BatteryManager *mgr = [obj objectAtIndex:0];
			active = [mgr isMonitoring];
		}
		if (active)
		{
			[toolbarItem setImage:[NSImage imageNamed:@"stop"]];
			[toolbarItem setLabel:NSLocalizedString(@"Stop", @"Stop")];
			[toolbarItem setPaletteLabel:NSLocalizedString(@"Stop Monitoring", @"Stop Monitoring")];
			[toolbarItem setToolTip:NSLocalizedString(@"Stop Monitoring", @"Stop Monitoring")];
		}
		else
		{
			[toolbarItem setImage:[NSImage imageNamed:@"resume"]];
			[toolbarItem setLabel:NSLocalizedString(@"Resume", @"Resume")];
			[toolbarItem setPaletteLabel:NSLocalizedString(@"Resume Monitoring", @"Resume Monitoring")];
			[toolbarItem setToolTip:NSLocalizedString(@"Resume Monitoring", @"Resume Monitoring")];
		}
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(stopResumeMonitoring:)];
	}
	else if ([itemIdent isEqual:MBLClearLogToolbarItemIdentifier])
	{
		[toolbarItem setImage:[NSImage imageNamed:@"clean"]];
		[toolbarItem setLabel: NSLocalizedString(@"Clear Log", @"Clear Log")];
		[toolbarItem setPaletteLabel: NSLocalizedString(@"Clear Log", @"Clear Log")];
		[toolbarItem setToolTip:NSLocalizedString(@"Clear Log", @"Clear Log")];
		[toolbarItem setTarget: self];
		[toolbarItem setAction: @selector(clearLog:)];
	}
	return toolbarItem;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
    return [NSArray arrayWithObjects:
		MBLSwitchViewToolbarItemIdentifier,
        MBLZoomToolbarItemIdentifier,
		MBLNavigatorToolbarItemIdentifier,
		NSToolbarSpaceItemIdentifier,
		MBLBalloonToolbarItemIdentifier,
		MBLSessionsToolbarItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		MBLStopResumeToolbarItemIdentifier,
		MBLDiagnosticsToolbarItemIdentifier,
		MBLInspectorToolbarItemIdentifier,
		nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
    return [NSArray arrayWithObjects:
		MBLSwitchViewToolbarItemIdentifier,
		MBLZoomToolbarItemIdentifier,
		MBLNavigatorToolbarItemIdentifier,
		MBLInspectorToolbarItemIdentifier,
		MBLOpenInConsoleToolbarItemIdentifier,
		MBLStopResumeToolbarItemIdentifier,
		MBLClearLogToolbarItemIdentifier,
		MBLSessionsToolbarItemIdentifier,
		MBLBalloonToolbarItemIdentifier,
		MBLEnergyPrefsToolbarItemIdentifier,
		MBLDiagnosticsToolbarItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
		nil];
}

@end

@implementation AppController (NSToolbarNotifications)

- (void)toolbarWillAddItem:(NSNotification *)notification
{
	// lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
    NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];

    if ([[addedItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier])
	{
        [addedItem setToolTip: NSLocalizedString(@"Print Document", @"Print Document")];
        [addedItem setTarget:self];
		[addedItem setAction:@selector(print:)];
    }
	else if ([[addedItem itemIdentifier] isEqual:MBLStopResumeToolbarItemIdentifier])
	{
		id obj = [managerController selectedObjects];
		if ([obj count] > 0)
		{
			BatteryManager *mgr = [obj objectAtIndex:0];
			if ([mgr isMonitoring])
			{
			}
		}
	}
	else if ([[addedItem itemIdentifier] isEqual:MBLSwitchViewToolbarItemIdentifier])
	{
		viewSwitcher = (NSSegmentedControl *)[addedItem view];
	}
	else if ([[addedItem itemIdentifier] isEqual:MBLZoomToolbarItemIdentifier])
	{
		zoomControl = (NSSegmentedControl *)[addedItem view];
		[self _updateZoomShiftControls];
	}
	else if ([[addedItem itemIdentifier] isEqual:MBLNavigatorToolbarItemIdentifier])
	{
		shiftControl = (NSSegmentedControl *)[addedItem view];
		[self _updateZoomShiftControls];
	}
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
	// handle removal of items.  We have an item that could be a target, so that needs to be reset
    NSToolbarItem *removedItem = [[notification userInfo] objectForKey: @"item"];

	if ([[removedItem itemIdentifier] isEqual:MBLStopResumeToolbarItemIdentifier])
	{
		stopResumeItem = nil;
	}
	else if ([[removedItem itemIdentifier] isEqual:MBLSwitchViewToolbarItemIdentifier])
	{
		viewSwitcher = nil;
	}
	else if ([[removedItem itemIdentifier] isEqual:MBLZoomToolbarItemIdentifier])
	{
		zoomControl = nil;
	}
	else if ([[removedItem itemIdentifier] isEqual:MBLNavigatorToolbarItemIdentifier])
	{
		shiftControl = nil;
	}
}

@end

@implementation AppController (NSToolbarValidation)

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
	// works just like menu item validation, but for the toolbar.
    BOOL ret = NO;
	
	if (!toolbarItem)
		return ret;
	
	if ([[toolbarItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLSwitchViewToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLSessionsToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLBalloonToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLEnergyPrefsToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLDiagnosticsToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLInspectorToolbarItemIdentifier] ||
		[[toolbarItem itemIdentifier] isEqual:MBLOpenInConsoleToolbarItemIdentifier])
	{
		ret = YES;
	}
	else if ([[toolbarItem itemIdentifier] isEqual:MBLZoomToolbarItemIdentifier] ||
			 [[toolbarItem itemIdentifier] isEqual:MBLNavigatorToolbarItemIdentifier])
	{
		
		[self _updateZoomShiftControls];
	}
	else if([[toolbarItem itemIdentifier] isEqual:MBLStopResumeToolbarItemIdentifier])
	{
		id obj = [managerController selectedObjects];
		if ([obj count] > 0)
		{
			BatteryManager *mgr = [obj objectAtIndex:0];
			if ([mgr isMonitoring])
			{
				[toolbarItem setImage:[NSImage imageNamed:@"stop"]];
				[toolbarItem setLabel: NSLocalizedString(@"Stop", @"Stop")];
				[toolbarItem setPaletteLabel: NSLocalizedString(@"Stop Monitoring", @"Stop Monitoring")];
				[toolbarItem setToolTip:NSLocalizedString(@"Stop Monitoring", @"Stop Monitoring")];
			}
			else
			{
				[toolbarItem setImage:[NSImage imageNamed:@"resume"]];
				[toolbarItem setLabel: NSLocalizedString(@"Resume", @"Resume")];
				[toolbarItem setPaletteLabel: NSLocalizedString(@"Resume Monitoring", @"Resume Monitoring")];
				[toolbarItem setToolTip:NSLocalizedString(@"Resume Monitoring", @"Resume Monitoring")];
			}		
			ret = YES;
		}
    }
	else if([[toolbarItem itemIdentifier] isEqual:MBLClearLogToolbarItemIdentifier])
	{
        ret = ([[logController arrangedObjects] count] > 0);
    }
    return ret;
}

@end

@implementation AppController (NSMenuValidation)

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	if ([menuItem action] == @selector(stopResumeMonitoring:))
	{
		BatteryManager *mgr = [[managerController selectedObjects] objectAtIndex:0];
		if ([mgr isMonitoring])
		{
			[menuItem setTitle:NSLocalizedString(@"Stop Monitoring", @"Stop Monitoring")];
		}
		else
		{
			[menuItem setTitle:NSLocalizedString(@"Resume Monitoring", @"Resume Monitoring")];
		}
	}
	else if ([menuItem action] == @selector(toggleSessionsBrowser:))
	{
		NSDrawerState state = [sessionsDrawer state];
		if (state == NSDrawerClosedState ||
			state == NSDrawerClosingState)
		{
			[menuItem setTitle:NSLocalizedString(@"Show Sessions Browser", @"Show Sessions Browser")];
		}
		else
		{
			[menuItem setTitle:NSLocalizedString(@"Hide Sessions Browser", @"Hide Sessions Browser")];
		}
	}
	else if ([menuItem action] == @selector(toggleSidebar:))
	{
		BOOL hidden = [[sidebarSplitView subviewAtPosition:0] isCollapsed];
		if (hidden)
		{
			[menuItem setTitle:NSLocalizedString(@"Show Sidebar", @"Show Sidebar")];
		}
		else
		{
			[menuItem setTitle:NSLocalizedString(@"Hide Sidebar", @"Hide Sidebar")];
		}
	}
	else if ([menuItem action] == @selector(toggleBatteryStatus:))
	{
		BOOL hidden = [[batteryStatusSplitView subviewAtPosition:1] isCollapsed];
		if (hidden)
		{
			[menuItem setTitle:NSLocalizedString(@"Show Battery Status", @"Show Battery Status")];
		}
		else
		{
			[menuItem setTitle:NSLocalizedString(@"Hide Battery Status", @"Hide Battery Status")];
		}
	}
	else if ([menuItem action] == @selector(clearLog:))
	{
		return ([[logController arrangedObjects] count] > 0);
	}
	else if ([menuItem action] == @selector(showWindow:))
	{
		return (![window isVisible] || ![NSApp isActive]);
	}
	else if ([menuItem action] == @selector(exportDataToCSV:))
	{
		NSMutableArray *arr = [sessionsController arrangedObjects];
		int sel = [sessionsController selectionIndex];
		return (arr &&
				sel > -1 &&
				sel < [arr count]);
	}
	else if ([menuItem action] == @selector(disconnectManager:))
	{
		id mgr = [[managerController selectedObjects] objectAtIndex:0];
		return [self isRegisteredRemoteService:mgr];
	}
	else if ([menuItem action] == @selector(disconnectAllManagers:))
	{
		NSArray *remoteManagers = [remoteServices allValues];
		return [remoteManagers count] > 0;
	}
	else if ([menuItem action] == @selector(removeAllSessions:))
	{
		return [sessionsController canRemoveAll];
	}
	return YES;
}

@end

@implementation AppController (NSTableViewNotifications)

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self showSession:nil];
}

@end

@implementation AppController (NSSplitViewDelegate)

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
	if ((sender == statsSplitView)/* ||
		(sender == sidebarSplitView)*/)
	{
		// Collapse only if first subview
		if (subview == [[sender subviews] objectAtIndex:0])
			return YES;
	}
	return NO;
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedCoord ofSubviewAt:(int)offset
{
	if (sender == statsSplitView)
	{
		switch (offset)
		{
			case 0:
				return 150;
			case 1:
				return 107;
		}
	}
	/*
	else if (sender == sidebarSplitView)
	{
		switch (offset)
		{
			case 0:
				return kMBLSidebarMinWidth;
			case 1:
				return kMBLChartMinWidth;
		}
	}
	 */
	return proposedCoord;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedCoord ofSubviewAt:(int)offset
{
	if (sender == statsSplitView)
	{
		switch (offset)
		{
			case 0:
				return [sender frame].size.height - [sender dividerThickness] - 107;
		}
	}
	/*
	else if (sender == sidebarSplitView)
	{
		switch (offset)
		{
			case 0:
				return [sender frame].size.width - kMBLChartMinWidth;
		}
	}
	 */
	return proposedCoord;	
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	if (sender == statsSplitView)
	{
		// how to resize a horizontal split view so that the left frame stays a constant size
		NSView *top = [[sender subviews] objectAtIndex:0];      // get the two sub views
		NSView *bottom = [[sender subviews] objectAtIndex:1];
		
		float dividerThickness = [sender dividerThickness];         // and the divider thickness
		NSRect newFrame = [sender frame];                           // get the new size of the whole splitView
		NSRect topFrame = [top frame];                            // current size of the top subview
		NSRect bottomFrame = [bottom frame];                          // ...and the bottom
		
		if ([sender isSubviewCollapsed:top])
		{
			bottomFrame.size.height = newFrame.size.height - dividerThickness;
			bottomFrame.size.width = newFrame.size.width;              // the whole width
			bottomFrame.origin.y = dividerThickness;  // 
			[bottom setFrame:bottomFrame];			
		}
		else
		{
			float bottomHeight = newFrame.size.height - topFrame.size.height - dividerThickness;
			if (bottomHeight < 107) bottomHeight = 107;

			bottomFrame.size.height = bottomHeight;
			bottomFrame.size.width = newFrame.size.width;
			bottomFrame.origin.y = newFrame.size.height - bottomHeight;

			topFrame.size.height = newFrame.size.height - dividerThickness - bottomHeight;
			topFrame.size.width = newFrame.size.width;
			topFrame.origin = NSZeroPoint;
			
			[top setFrame:topFrame];
			[bottom setFrame:bottomFrame];
		}
	}
}

@end

@implementation AppController (NSTableViewDelegate)

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn row:(int)row mouseLocation:(NSPoint)mouseLocation
{
	// We are using the delegate method to show a tooltip to
	// get the opportunity to show a preview of the session
	// currently hovered by the mouse.
	// This will work only in Tiger and above.
	if (aTableView == sessionsView)
	{
		if (!sessionPreviewController)
		{
			sessionPreviewController = [[SessionPreviewController alloc] init];
		}
		[sessionPreviewController setSession:[[sessionsController arrangedObjects] objectAtIndex:row]];
		
		NSPoint pt1 = [sessionsView convertPoint:mouseLocation toView:nil];
		NSPoint translated = [[sessionsView window] convertBaseToScreen:pt1];
		//NSLog(@"%@", NSStringFromPoint(translated));
		[[sessionPreviewController window] setFrameOrigin:NSMakePoint(translated.x + 10.0, translated.y + 10.0)];
		[sessionPreviewController showWindow:self];
		[[sessionPreviewController window] orderFront:nil];
	}
	return nil;
}

- (void)tableView:(NSTableView *)tv willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{	
	if (tv == managersList)
	{
		if ([[tableColumn identifier] isEqual:@"mgr_name"])
		{
			// If the row is selected but isn't being edited and the current drawing isn't being used to create a drag image,
			// colour the text white; otherwise, colour it black
			NSColor *fontColor = ( [[tv selectedRowIndexes] containsIndex:rowIndex] && ([tv editedRow] != rowIndex) && (![[tv draggedRows] containsIndex:rowIndex]) ) ?
			[NSColor whiteColor] : [NSColor blackColor];
			[cell setTextColor:fontColor];
		}
	}
}

@end

@implementation AppController (NSTableDataSource)

/* Mac OS X 10.4 or later
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard 
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:MyPrivateTableViewDataType] owner:self];
    [pboard setData:data forType:MyPrivateTableViewDataType];
    return YES;
}
*/

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return -1; //[[sessionsController arrangedObjects] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return nil;
}

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	// Dragging out carries a session's CSV data
	
	// Apply changes
	[sessionsController commitEditing];
	NSArray *arr = (NSArray *)[sessionsController arrangedObjects];
	int sel = [[rows objectAtIndex:0] intValue];
	
	// Annotate table row that is being dragged
	[sessionsView setDraggedRow:sel];
	
	// Get CSV stream
	NSString *CSVString = [[[arr objectAtIndex:sel] events] CSVString];
	
	// Declare pasteboard types
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	
	// Put data into pasteboard
	[pboard setString:CSVString forType:NSStringPboardType];
	
	return YES;
}

@end

@implementation AppController (RBSplitViewDelegate)

// This makes it possible to drag the first divider around by the dragView.
- (unsigned int)splitView:(RBSplitView*)sender dividerForPoint:(NSPoint)point inSubview:(RBSplitSubview*)subview {
	if (subview == sidebar) {
		if ([dragView mouse:[dragView convertPoint:point fromView:sender] inRect:[dragView bounds]]) {
			return 0;	// [sidebar position], which we assume to be zero
		}
	}
	return NSNotFound;
}

// This changes the cursor when it's over the dragView.
- (NSRect)splitView:(RBSplitView*)sender cursorRect:(NSRect)rect forDivider:(unsigned int)divider {
	if (divider == 0) {
		[sender addCursorRect:[dragView convertRect:[dragView bounds] toView:sender] cursor:[RBSplitView cursor:RBSVVerticalCursor]];
	}
	return rect;
}

- (NSRect)splitView:(RBSplitView*)sender willDrawDividerInRect:(NSRect)dividerRect betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing withProposedRect:(NSRect)imageRect
{
	// Let's draw the background of the divider ourselves
	[sender lockFocus];
	[[NSColor controlShadowColor] set];
	[NSBezierPath fillRect:dividerRect];
	[sender unlockFocus];
	
	return NSZeroRect;//dividerRect;
}

- (void)splitView:(RBSplitView*)sender didCollapse:(RBSplitSubview*)subview
{
	// Update the MBLSidebarHidden preference
	if (subview == [sidebarSplitView subviewAtPosition:0])
	{
		//NSLog(@"%d", [subview isCollapsed]);
		/*
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
												   forKey:MBLSidebarHiddenKey];
		*/
	}
}
- (void)splitView:(RBSplitView*)sender didExpand:(RBSplitSubview*)subview
{
	// Update the MBLSidebarHidden preference
	if (subview == [sidebarSplitView subviewAtPosition:0])
	{
		//NSLog(@"%d", [subview isCollapsed]);
		/*
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO]
												  forKey:MBLSidebarHiddenKey];
		*/
	}
}

@end
