//
//  RecallController.h
//  MiniBatteryLogger
//
//  Created by delphine on 15-05-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	MBLBatteryRecalliBookPBookBatteryExchangeTab = 1,
	MBLBatteryRecallMacBookBatteryUpdateTab = 2,
	MBLBatteryRecallNotEligibleTab = 3
};

@interface NSString (BatteryRecallExtensions)

/* Returns YES if the serial number is eligible for the battery exchange program */
- (BOOL)isEligibleForiBookNPowerBookExchangeProgram;

@end

@class AppController;

@interface RecallController : NSWindowController {

	NSDictionary *countriesDict;
	
	IBOutlet NSPopUpButton *countryChooser;
	IBOutlet NSTextField *computerSerialNumberField;
	IBOutlet NSTextField *batterySerialNumberField;

	AppController *appController;
}

- (void)setAppController:(AppController *)controller;

- (IBAction)onlineHelp:(id)sender;
- (IBAction)countryChanged:(id)sender;
- (IBAction)moreInfo:(id)sender;
- (IBAction)checkiBookNPowerBookBatteryExchangeEligibility:(id)sender;

@end
