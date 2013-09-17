//
//  PreferenceController.m
//  MiniBatteryLogger
//
//  Created by delphine on 30-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "PreferenceController.h"

@implementation PreferenceController

- (id)init
{
	// create the preference window controller
	// create style mask
	unsigned int styleMask = (NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSUnifiedTitleAndToolbarWindowMask);
	self = [[AMPreferenceWindowController alloc] initWithAutosaveName:@"PreferencePanel"
													  windowStyleMask:styleMask];
	
	/*
	 // Hide the "pill" toolbar button
	 [[[[self window] standardWindowButton:NSWindowToolbarButton] retain] removeFromSuperview];
	 */
	
	/*
	 // load plugins from the bundle's standard plugins folder
	 [prefsWindow addPluginsOfType:nil fromPath:[[NSBundle mainBundle] builtInPlugInsPath]];
	 */		
	
	// Adding general preferences pane
	id <AMPrefPaneProtocol> pane = [[[GeneralPreferencePane alloc] initWithIdentifier:@"pane1"
																				label:NSLocalizedString(@"General", @"General")
																			 category:@"Main"] autorelease];
	[self addPane:pane withIdentifier:[pane identifier]];
	// Adding chart view preferences pane
	pane = [[[ChartViewPreferencePane alloc] initWithIdentifier:@"pane2"
														  label:NSLocalizedString(@"Chart View", @"Chart View")
													   category:@"Main"] autorelease];
	[self addPane:pane withIdentifier:[pane identifier]];
	// Adding notifications preferences pane
	pane = [[[NotificationsPreferencePane alloc] initWithIdentifier:@"pane3"
															  label:NSLocalizedString(@"Alerts", @"Alerts")
														   category:@"Main"] autorelease];
	[self addPane:pane withIdentifier:[pane identifier]];		

	// Adding software update preferences pane
	pane = [[[SWUpdatePreferencePane alloc] initWithIdentifier:@"pane4"
														 label:NSLocalizedString(@"Software Update", @"Software Update")
													  category:@"Main"] autorelease];	
	[self addPane:pane withIdentifier:[pane identifier]];

	// Adding registration preferences pane
	pane = [[[RegistrationPreferencePane alloc] initWithIdentifier:@"pane5"
															 label:NSLocalizedString(@"Registration", @"Registration")
														  category:@"Main"] autorelease];
	[self addPane:pane withIdentifier:[pane identifier]];
	
	// Adding sharing preferences pane
	pane = [[[SharingPreferencePane alloc] initWithIdentifier:@"pane6"
														 label:NSLocalizedString(@"Sharing", @"Sharing")
													  category:@"Main"] autorelease];
	[self addPane:pane withIdentifier:[pane identifier]];		

	/*
	// Adding actions preferences pane
	pane = [[[ActionsPreferencePane alloc] initWithIdentifier:@"pane7"
														label:NSLocalizedString(@"Actions", @"Actions")
													 category:@"Main"] autorelease];
	[self addPane:pane withIdentifier:[pane identifier]];		
	*/
	// set up some configuration options
	[self setUsesConfigurationPane:NO];
	[self setSortByCategory:NO];
	
	// select prefs pane for display
	[self selectPaneWithIdentifier:@"pane1"];
	
	return self;
}

@end