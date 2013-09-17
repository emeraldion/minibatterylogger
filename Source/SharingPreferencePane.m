//
//  SharingPreferencePane.m
//  MiniBatteryLogger
//
//  Created by delphine on 9-10-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "SharingPreferencePane.h"

extern NSString *MBLSendOwnDataKey;
extern NSString *MBLRetrieveDataKey;
extern NSString *MBLShareOwnDataKey;
extern NSString *MBLLookForSharedDataKey;
extern NSString *MBLShareWithPasswordKey;
extern NSString *MBLAdvertiseServiceKey;
extern NSString *MBLSharingPasswordKey;

extern NSString *MBLShareOwnDataChangedNotification;
extern NSString *MBLLookForSharedDataChangedNotification;
extern NSString *MBLAdvertiseServiceChangedNotification;

@class CPSystemInformation;

@implementation SharingPreferencePane

- (id)initWithIdentifier:(NSString *)theIdentifier
				   label:(NSString *)theLabel
				category:(NSString *)theCategory
{
	if (self = [super initWithIdentifier:theIdentifier
								   label:theLabel
								category:theCategory])
	{
		[self setIcon:[NSImage imageNamed:@"sharing"]];
	}
	return self;
}

- (void)dealloc
{
	if (kcItemRef)
		CFRelease(kcItemRef);
	[super dealloc];
}

- (void)mainViewDidLoad
{
	[sendOwnDataButton setState:[self shouldSendOwnData]];
	[retrieveDataButton setState:[self shouldRetrieveData]];
	
	BOOL share = [self shouldShareOwnData];
	BOOL ask = [self shouldAskSharingPassword];
	
	[shareWithPasswordButton setState:ask];
	[sharingPasswordField setStringValue:[self sharingPassword]];
	[lookForSharedDataButton setState:[self shouldLookForSharedData]];
	[shareOwnDataButton setState:share];
	[dontAdvertiseServiceButton setState:![self shouldAdvertiseService]];

	[shareWithPasswordButton setEnabled:share];
	[sharingPasswordField setEnabled:share && ask];
	[dontAdvertiseServiceButton setEnabled:share];
}

#pragma mark === Preferences retrieval ===

- (BOOL)shouldSendOwnData
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLSendOwnDataKey] boolValue];	
}

- (BOOL)shouldRetrieveData
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLRetrieveDataKey] boolValue];	
}

- (BOOL)shouldAskSharingPassword
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLShareWithPasswordKey] boolValue];	
}

- (BOOL)shouldShareOwnData
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLShareOwnDataKey] boolValue];	
}

- (BOOL)shouldLookForSharedData
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLLookForSharedDataKey] boolValue];	
}

- (BOOL)shouldAdvertiseService
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:MBLAdvertiseServiceKey] boolValue];	
}

- (NSString *)sharingPassword
{
	unsigned char *passwordData = nil;
	UInt32 passwordLength;
	
	NSString *serviceNameStr = @"MiniBatteryLogger Battery Data Sharing";
	void *serviceName = (void *)[serviceNameStr UTF8String];
	UInt32 serviceNameLength = [serviceNameStr length];
	
	NSString *acctNameStr = [CPSystemInformation computerName];
	void *acctName = (void *)[acctNameStr UTF8String];
	UInt32 acctNameLength = [acctNameStr length];
	
	OSErr status = SecKeychainFindGenericPassword (
												  NULL,				// default keychain
												  serviceNameLength,// length of service name
												  serviceName,		// service name
												  acctNameLength,   // length of account name
												  acctName,			// account name
												  &passwordLength,	// length of password
												  &passwordData,	// pointer to password data
												  &kcItemRef		// the item reference
												  );
	if (status == noErr)
	{
		NSString *pass = [NSString stringWithCString:passwordData length:passwordLength];
		status = SecKeychainItemFreeContent (
											 NULL,           //No attribute data to release
											 passwordData    //Release data buffer allocated by 
															 //SecKeychainFindGenericPassword
											 );
		return pass;
	}
	return @"";
}

#pragma mark === Actions ===

- (IBAction)changeSendOwnData:(id)sender
{
	// This setting affects subsequent startup so all is required
	// is to set the user default
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLSendOwnDataKey];
}
- (IBAction)changeRetrieveData:(id)sender
{
	// This setting affects subsequent startup so all is required
	// is to set the user default
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLRetrieveDataKey];
}

- (IBAction)changeShareOwnData:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLShareOwnDataKey];

	// Notify so the server can shutdown / start
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLShareOwnDataChangedNotification
														object:self];
	
	[shareWithPasswordButton setEnabled:[sender state]];
	[sharingPasswordField setEnabled:[sender state] && [self shouldAskSharingPassword]];
	[dontAdvertiseServiceButton setEnabled:[sender state]];
}

- (IBAction)changeLookForSharedData:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLLookForSharedDataKey];
	
	// Notify so the service browser can be started / stopped
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLLookForSharedDataChangedNotification
														object:self];	
}

- (IBAction)changeAdvertiseService:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLAdvertiseServiceKey];

	// Notify so the service browser can be started / stopped
	[[NSNotificationCenter defaultCenter] postNotificationName:MBLAdvertiseServiceChangedNotification
														object:self];	
	
}

- (IBAction)changeSharingPassword:(id)sender
{
	OSStatus status;
	UInt32 passwordLength = [[sender stringValue] length];
	unsigned char *password = [[sender stringValue] UTF8String];
		
	if (!kcItemRef)
	{
		NSString *serviceNameStr = NSLocalizedString(@"MiniBatteryLogger Battery Data Sharing", @"MiniBatteryLogger Battery Data Sharing");
		void *serviceName = (void *)[serviceNameStr UTF8String];
		UInt32 serviceNameLength = [serviceNameStr length];
		
		NSString *acctNameStr = [CPSystemInformation computerName];
		void *acctName = (void *)[acctNameStr UTF8String];
		UInt32 acctNameLength = [acctNameStr length];
		
		status = SecKeychainAddGenericPassword (
												NULL,				// default keychain
												serviceNameLength,	// length of service name
												serviceName,		// service name
												acctNameLength,		// length of account name
												acctName,			// account name
												passwordLength,		// length of password
												password,			// pointer to password data
												NULL				// the item reference
												);
	}
	else
	{
		status = SecKeychainItemModifyAttributesAndData (
														 kcItemRef,		// the item reference
														 NULL,			// no change to attributes
														 passwordLength,// length of password
														 password		// pointer to password data
														 );
	}
}

- (IBAction)changeShareWithPassword:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[sender state]]
											  forKey:MBLShareWithPasswordKey];

	[sharingPasswordField setEnabled:[sender state]];
	if ([sender state])
	{
		[sharingPasswordField selectText:sender];
	}
}

@end
