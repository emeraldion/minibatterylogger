//
//  SharingPreferencePane.h
//  MiniBatteryLogger
//
//  Created by delphine on 9-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>
#import <CoreServices/CoreServices.h>
#import "MBLPreferencePane.h"

@interface SharingPreferencePane : MBLPreferencePane
{
	IBOutlet NSButton *sendOwnDataButton;
	IBOutlet NSButton *retrieveDataButton;
	
	IBOutlet NSButton *shareOwnDataButton;
	IBOutlet NSButton *dontAdvertiseServiceButton;
	IBOutlet NSButton *lookForSharedDataButton;
	IBOutlet NSButton *shareWithPasswordButton;
	
	IBOutlet NSSecureTextField *sharingPasswordField;
	
	SecKeychainItemRef kcItemRef;
}

- (IBAction)changeSendOwnData:(id)sender;
- (IBAction)changeRetrieveData:(id)sender;

- (IBAction)changeShareOwnData:(id)sender;
- (IBAction)changeLookForSharedData:(id)sender;
- (IBAction)changeAdvertiseService:(id)sender;
- (IBAction)changeSharingPassword:(id)sender;
- (IBAction)changeShareWithPassword:(id)sender;

- (BOOL)shouldSendOwnData;
- (BOOL)shouldRetrieveData;
- (BOOL)shouldAskSharingPassword;
- (BOOL)shouldShareOwnData;
- (BOOL)shouldAdvertiseService;
- (BOOL)shouldLookForSharedData;
- (NSString *)sharingPassword;

@end

