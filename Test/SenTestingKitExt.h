/*
 *  SenTestingExt.h
 *  MiniBatteryLogger
 *
 *  Created by delphine on 22-05-2008.
 *  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
 *
 */

#import <SenTestingKit/SenTestingKit.h>

#define STAssertApplicationLaunched(appName, description, ...) \
do { \
    @try {\
		NSArray *launchedApplications = [[NSWorkspace sharedWorkspace] launchedApplications]; \
        int i; \
		for (i = 0; i < [launchedApplications count]; i++) { \
			NSDictionary *dict = [launchedApplications objectAtIndex:i]; \
			if ([[dict objectForKey:@"NSApplicationName"] isEqualToString:(appName)]) \
			{ \
				return; \
			} \
		} \
		[self failWithException:[NSException failureInFile:[NSString stringWithCString:__FILE__] \
													atLine:__LINE__ \
										   withDescription:[[NSString stringWithFormat:@"Application not launched %@ -- ", (appName)] stringByAppendingString:STComposeString(description, ##__VA_ARGS__)]]]; \
    }\
    @catch (id anException) {\
        [self failWithException:[NSException failureInRaise:[NSString stringWithFormat: @"Application launched: %@", (appName)] \
                                                  exception:anException \
                                                     inFile:[NSString stringWithCString:__FILE__] \
                                                     atLine:__LINE__ \
                                            withDescription:STComposeString(description, ##__VA_ARGS__)]]; \
    }\
} while(0)
