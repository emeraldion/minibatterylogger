//
//  GeneralPreferencePane.h
//  MiniBatteryLogger
//
//
//  Created by delphine on 31-08-2006.
//	Buon compleanno, fratello scemo
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLPreferencePane.h"

@interface GeneralPreferencePane : MBLPreferencePane
{	
	IBOutlet NSTextField *timeField;
	IBOutlet NSSlider *timeSlider;
	IBOutlet NSButton *displayIconButton;
	IBOutlet NSButton *startMonitoringAtLaunchButton;
	IBOutlet NSButton *startupItemButton;
	IBOutlet NSButton *saveOnQuitButton;
	IBOutlet NSButton *hideDockIconButton;
	IBOutlet NSButton *displayStatusItemButton;
	IBOutlet NSButton *autoSaveSessionsButton;
	IBOutlet NSButton *showDesktopBatteryButton;
}

- (IBAction)changeProbeInterval:(id)sender;
- (IBAction)changeSetting:(id)sender;

- (int)probeInterval;
- (BOOL)shouldDisplayCustomIcon;
- (BOOL)isLoginItem;
- (BOOL)shouldHideDockIcon;
- (BOOL)shouldSaveOnQuit;
- (BOOL)shouldDisplayStatusItem;
- (BOOL)shouldShowDesktopBattery;
- (BOOL)shouldAutoSaveSessions;
- (BOOL)shouldStartMonitoringAtLaunch;

@end
