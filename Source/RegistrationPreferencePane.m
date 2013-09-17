//
//  RegistrationPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "RegistrationPreferencePane.h"

static NSString *MBLRegistrationURL			= @"http://www.emeraldion.it/software/macosx/minibatterylogger/register.html?me=%@";
static NSString *MBLLostLicenseURL			= @"http://www.emeraldion.it/software/macosx/minibatterylogger/register/lost-license.html?me=%@";

NSString *MBLDefaultsRegisteredUserKey		= @"MBLRegisteredUser";
NSString *MBLDefaultsRegistrationKeyKey		= @"MBLRegistrationKey";

@class AppController;

@implementation RegistrationPreferencePane

- (id)initWithIdentifier:theIdentifier
				   label:theLabel
				category:theCategory
{
	if (self = [super initWithIdentifier:(NSString *)theIdentifier
								   label:(NSString *)theLabel
								category:(NSString *)theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"registration"]];
	}
	return self;
}

- (void)dealloc
{
	[_license release];
	[super dealloc];
}

- (void)mainViewDidLoad
{
	if ([[AppController sharedController] isRegistered])
	{
		[self showRegistrationInfo];
	}
	else
	{
		[tabView selectTabViewItemAtIndex:0];
	}
}

- (IBAction)registerOnline:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:MBLRegistrationURL,
		[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
	
}

- (IBAction)retrieveLostLicense:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithFormat:MBLLostLicenseURL,
		[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]]];
}

- (IBAction)enterRegistration:(id)sender
{
	if ([[AppController sharedController] registerToUser:[[NSUserDefaults standardUserDefaults] valueForKey:MBLDefaultsRegisteredUserKey]
													 key:[[NSUserDefaults standardUserDefaults] valueForKey:MBLDefaultsRegistrationKeyKey]])
	{
		[self showRegistrationInfo];
	}
	else
	{
		NSBeep();
	}
}

- (IBAction)changeRegistration:(id)sender
{
	[tabView selectTabViewItemAtIndex:0];
}

- (void)showRegistrationInfo
{
	_license = [[MBLLicense alloc] initWithUsername:[[NSUserDefaults standardUserDefaults] valueForKey:MBLDefaultsRegisteredUserKey]
												key:[[NSUserDefaults standardUserDefaults] valueForKey:MBLDefaultsRegistrationKeyKey]];
				
	NSData *imageData = [[[ABAddressBook sharedAddressBook] me] imageData];
	NSImage *userImage = [[NSImage alloc] initWithData:imageData];
	
	// Fill in the registration informations fields
	[userIcon setImage:userImage];
	[userFullnameField setStringValue:[[NSUserDefaults standardUserDefaults] valueForKey:MBLDefaultsRegisteredUserKey]];
	[licenseTypeField setStringValue:[MBLLicense descriptionForLicenseType:[_license licenseType]]];
	[licenseValidityField setStringValue:[[_license startDate] descriptionWithCalendarFormat:NSLocalizedString(@"%m/%d/%Y", @"%m/%d/%Y")]];
		
	// Show the informations tab view
	[tabView selectTabViewItemAtIndex:1];	
}

@end
