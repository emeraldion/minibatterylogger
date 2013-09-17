//
//  NotificationsPreferencePane.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLTypes.h"
#import "MBLPreferencePane.h"

@interface NotificationsPreferencePane : MBLPreferencePane
{
	/* Low Battery */
	IBOutlet NSTextField *lowLevelField;
	IBOutlet NSSlider *lowLevelSlider;

	/* Battery Dying */
	IBOutlet NSTextField *dyingLevelField;
	IBOutlet NSSlider *dyingLevelSlider;
	
	/* Alert using */
	IBOutlet NSButton *testButton;
	IBOutlet NSPopUpButton *alertModeChooser;
}

- (int)lowAlertLevel;
- (int)dyingAlertLevel;
- (MBLAlertMode)alertMode;

- (IBAction)changeLowAlertLevel:(id)sender;
- (IBAction)changeDyingAlertLevel:(id)sender;
- (IBAction)changeAlertMode:(id)sender;
- (IBAction)testAlert:(id)sender;

/* Commodity method to handle level changes */
- (void)changeLevel:(id)sender field:(NSTextField *)field key:(NSString *)key;

/* Alert sheet handler */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

@end
