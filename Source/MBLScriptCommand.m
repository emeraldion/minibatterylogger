//
//  MBLScriptCommand.m
//  MiniBatteryLogger
//
//  Created by delphine on 1-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLScriptCommand.h"

static NSString *MBLScriptCommandRegisterVerb	= @"register";
static NSString *MBLScriptCommandConnectVerb	= @"connect";

@class AppController;

@implementation MBLScriptCommand

/**
*	This is the default method called after receiving an AppleEvent
 */
- (id)performDefaultImplementation
{
	// This method is called when any URL with the scheme mbl:// is called
	
	// Retrieve the contents sent by the URL and break it into an array
	NSArray *registrationInfo = [[self directParameter] componentsSeparatedByString:@"/"];
	
	// We now have an array that /should/ have some info in it
	// The values we care about are:
	// [registrationInfo objectAtIndex:2] // The desired operation
	NSString *verb = [[registrationInfo objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	
	if ([verb isEqualTo:MBLScriptCommandRegisterVerb] && [registrationInfo count] == 6) // Valid URL
	{
		// [registrationInfo objectAtIndex:3] // The email of the registrant
		// [registrationInfo objectAtIndex:4] // The name of the registrant
		// [registrationInfo objectAtIndex:5] // The serial number
		// If it's a registration URL without six fields, we'll assume it's invalid
		NSString *email = [[registrationInfo objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		NSString *username = [[registrationInfo objectAtIndex:4] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		NSString *key = [[registrationInfo objectAtIndex:5] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];		
		// Validate the information
		if ([[AppController sharedController] registerToUser:username key:key])
		{
			return nil; // We're done here.
		}
		// Something failed along the way.  Hopefully you'll include a nice button to email you.
		if (NSRunAlertPanel(NSLocalizedString(@"Registration error", @"Registration error"),
							NSLocalizedString(@"There was a problem activating your copy of MiniBatteryLogger.", @"There was a problem activating your copy of MiniBatteryLogger."),
							NSLocalizedString(@"OK", @"OK"),
							nil,
							nil) == NSAlertOtherReturn)
		{
			//Do something
		}		
	}
	else if ([verb isEqualTo:MBLScriptCommandConnectVerb] && [registrationInfo count] == 4) // Valid URL
	{
		NSString *address = [[registrationInfo objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[[AppController sharedController] connectToAddress:address];
		return nil; // We're done here.
	}
	return nil;
}

@end
