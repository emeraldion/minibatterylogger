//
//  RegistrationPreferencePane.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import "MBLPreferencePane.h"
#import "MBLLicense.h"

@interface RegistrationPreferencePane : MBLPreferencePane
{	
	IBOutlet NSTabView *tabView;
	IBOutlet NSImageView *userIcon;
	IBOutlet NSTextField *userFullnameField;
	IBOutlet NSTextField *licenseTypeField;
	IBOutlet NSTextField *licenseValidityField;	

	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *keyField;
	
	MBLLicense *_license;
}

- (IBAction)registerOnline:(id)sender;
- (IBAction)retrieveLostLicense:(id)sender;
- (IBAction)enterRegistration:(id)sender;
- (IBAction)changeRegistration:(id)sender;

@end
