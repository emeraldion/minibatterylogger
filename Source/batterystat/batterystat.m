/*
 *  batterystat.c
 *  MiniBatteryLogger
 *
 *  Created by delphine on 28-02-2007.
 *  Copyright 2007 Claudio Procida. All rights reserved.
 *
 */

#import "batterystat.h"
#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>
#import "Battery.h"
#import "LocalBatteryManager.h"
#import "DemoBatteryManager.h"
#import "RemoteBatteryManager.h"
#import "SecondsToMinutesTransformer.h"

#define PAD_LENGTH 24

/*!
 @category batterystat
 @abstract Methods for <tt>Battery</tt> class used by the <tt>batterystat</tt> commandline tool.
 */
@interface Battery (batterystat)

/*!
 @method descriptionForCommandline
 @abstract Returns a string representation of the receiver that is suitable
 for a commandline output.
 */
- (NSString *)descriptionForCommandline;

/*!
 @method manufactureInfoForCommandline
 @abstract Returns a string representation of the manufacture information of the receiver,
 suitable for a commandline output.
 */
- (NSString *)manufactureInfoForCommandline;

/*!
 @method timesInfoForCommandline
 @abstract Returns a string representation of information regarding timers of the receiver,
 e.g. time to full charge, suitable for a commandline output.
 */
- (NSString *)timesInfoForCommandline;

@end

@implementation Battery (batterystat)

- (NSString *)descriptionForCommandline
{
	return [NSString stringWithFormat:@"\
Charge:          %24d %%\n\
Capacity:        %24d mAh\n\
Max Capacity:    %24d mAh\n\
Design Capacity: %24d mAh\n\
Amperage:        %24d mA\n\
Voltage:         %24d mV\n\
Cycle Count:     %24d\n\
Power Source:    %@\n\
Charging:        %@",
		[self charge],
		[self capacity],
		[self maxCapacity],
		[self designCapacity],
		[self amperage],
		[self voltage],
		[self cycleCount],
		[([self isPlugged] ? @"AC Power" : @"Battery Power") stringByPaddingToLength:PAD_LENGTH
																		  withString:@" "
																	 startingAtIndex:0
																		   alignment:NSRightTextAlignment],
		[([self isCharging] ? @"Yes" : @"No") stringByPaddingToLength:PAD_LENGTH
														   withString:@" "
													  startingAtIndex:0
															alignment:NSRightTextAlignment]];
}

- (NSString *)manufactureInfoForCommandline
{
	return [NSString stringWithFormat:@"\
Manufacturer:    %@\n\
Manufacture Date:%@\n\
Model:           %@\n\
Serial Number:   %@",
		[([self manufacturer] != nil ? [self manufacturer] : @"N/A") stringByPaddingToLength:PAD_LENGTH
																				  withString:@" "
																			 startingAtIndex:0
																				   alignment:NSRightTextAlignment],
		[([self manufactureDate] != nil ? [[self manufactureDate] descriptionWithCalendarFormat:@"%Y-%m-%d"] : @"N/A") stringByPaddingToLength:PAD_LENGTH
																																	withString:@" "
																															   startingAtIndex:0
																																	 alignment:NSRightTextAlignment],
		[([self deviceName] != nil ? [self deviceName] : @"N/A") stringByPaddingToLength:PAD_LENGTH
																			  withString:@" "
																		 startingAtIndex:0
																			   alignment:NSRightTextAlignment],
		[([self serial] != nil ? [self serial] : @"N/A") stringByPaddingToLength:PAD_LENGTH
																	  withString:@" "
																 startingAtIndex:0
																	   alignment:NSRightTextAlignment]];
}

- (NSString *)timesInfoForCommandline
{
	SecondsToMinutesTransformer *transformer = [[[SecondsToMinutesTransformer alloc] initWithMode:MBLSecondsToMinutesTransformerCompactMode] autorelease];
	return [NSString stringWithFormat:@"\
Time to Empty:   %@ h\n\
Time to Full:    %@ h",
		[[transformer transformedValue:[NSNumber numberWithDouble:[self timeToEmpty]]] stringByPaddingToLength:PAD_LENGTH
																									withString:@" "
																							   startingAtIndex:0
																									 alignment:NSRightTextAlignment],
		[[transformer transformedValue:[NSNumber numberWithDouble:[self timeToFullCharge]]] stringByPaddingToLength:PAD_LENGTH
																										 withString:@" "
																									startingAtIndex:0
																										  alignment:NSRightTextAlignment]];
}

@end

/*!
 @category batterystat
 @abstract Methods for <tt>NSString</tt> class used by the <tt>batterystat</tt> commandline tool.
 */
@interface NSString (batterystat)

/*!
 @method stringByPaddingToLength:withString:startingAtIndex:alignment:
 @abstract Returns the receiver, padded to <tt>length</tt> characters with <tt>padString</tt>, with the desired alignment.
 @param length The length to which the receiver should be padded.
 @param padString The string used to pad the receiver.
 @param index Start from this position of padString.
 @param alignment An alignment for padding.
 */
- (NSString *)stringByPaddingToLength:(unsigned int)length withString:(NSString *)padString startingAtIndex:(unsigned int)index alignment:(NSTextAlignment)alignment;

@end

@implementation NSString (batterystat)

- (NSString *)stringByPaddingToLength:(unsigned int)length withString:(NSString *)padString startingAtIndex:(unsigned int)padIndex alignment:(NSTextAlignment)alignment
{
	if (alignment == NSRightTextAlignment)
	{
		int diff = length - [self length];
		if (diff > 0)
		{
			NSString *leftPad = [@"" stringByPaddingToLength:diff
												  withString:padString
											 startingAtIndex:padIndex];
			return [leftPad stringByAppendingString:self];
		}
		return self;
	}
	else
	{
		return [self stringByPaddingToLength:length
								  withString:padString
							 startingAtIndex:padIndex];
	}		
}

@end

static int xml, manufacture, prop, times;
static char *propname;

static void usage()
{
	fprintf(stderr, "batterystat (c) Claudio Procida 2006-2008\n");
	fprintf(stderr, "Usage: batterystat [options ...]\n");
	fprintf(stderr, "Options:\n");
	fprintf(stderr, "-a    Connect to remote battery address.\n");
	fprintf(stderr, "-c    Prints count of local batteries and exits.\n");
	fprintf(stderr, "-m    Include battery hardware manufacturing information.\n");
	fprintf(stderr, "-n    Index of battery for which you want information. Defaults to 1.\n");
	fprintf(stderr, "-p    Return the value of a single property. Allowed property names are: charge,\n");
	fprintf(stderr, "      amperage, capacity, maxCapacity, designCapacity, voltage, cycleCount,\n");
	fprintf(stderr, "      plugged, charging, manufacturer, manufactureDate, serial, deviceName,\n");
	fprintf(stderr, "      timeToEmpty, timeToFullCharge. If not used, all properties are returned.\n");
	fprintf(stderr, "-t    Include time information.\n");
	fprintf(stderr, "-v    Prints version number and exits.\n");
	fprintf(stderr, "-x    XML output.\n");
	fprintf(stderr, "-?/-h Prints this screen and exits.\n");
	
	exit(1);
}

static void version()
{
	fprintf(stderr, "batterystat version 1.4.91 (c) Claudio Procida 2006-2009\n");
	fprintf(stderr, "All rights reserved worldwide.\n");
	
	exit(0);
}

static void print_battery(Battery *batt)
{
	if (xml)
	{
		CFShow([batt xmlDescription]);
	}
	else
	{
		if (prop)
		{
			id val;
			@try
			{
				val = [batt valueForKey:[NSString stringWithUTF8String:propname]];
				if ([val isKindOfClass:[NSString class]])
				{
					CFShow(val);
				}
				else if ([val respondsToSelector:@selector(intValue)])
				{
					printf("%d\n", [val intValue]);
				}
			}
			@catch(NSException *exception)
			{
				fprintf(stderr, "Unknown property name: %s\n", propname);
			}
			@finally
			{
				// Do nothing
			}
		}
		else
		{
			CFShow([batt descriptionForCommandline]);
			if (times)
			{
				CFShow([batt timesInfoForCommandline]);
			}
			if (manufacture)
			{
				CFShow([batt manufactureInfoForCommandline]);
			}
		}
	}	
}

int main(int argc, char **argv)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int index, ch, count, demo, remote;
	char *addr;
	
	index = 0;
	count = 0;
	manufacture = 0;
	demo = 0;
	xml = 0;
	remote = 0;
	prop = 0;
	times = 0;
	
	while ((ch = getopt(argc, argv, "a:cdhmn:p:tvx?")) != -1) {
		switch (ch) {
			case 'x':
				xml = 1;
				break;
			case 'd':
				demo = 1;
				break;
			case 'c':
				count = 1;
				break;
			case 'a':
				remote = 1;
				addr = optarg;
				break;
			case 'm':
				manufacture = 1;
				break;
			case 'n':
				index = atoi(optarg) - 1;
				break;
			case 'p':
				propname = optarg;
				prop = 1;
				break;
			case 't':
				times = 1;
				break;
			case 'v':
				version();
				break;
			case '?':
			default:
				usage();
		}
	}
	argc -= optind;
	argv += optind;
	
	if (count)
	{
		printf("%d installed batteries.\n", [LocalBatteryManager installedBatteries]);
	}
	else if (remote)
	{
		NSString *address = [NSString stringWithUTF8String:addr];
		RemoteBatteryManager *manager = [[RemoteBatteryManager alloc] initWithRemoteAddress:address index:index];
		[manager setMonitoring:NO];
		[manager probeBattery];
		
		// 2 seconds should be enough to get a response from the remote battery
		sleep(2);

		print_battery([manager battery]);

		[manager release];
	}
	else if (demo)
	{
		DemoBatteryManager *manager = [[DemoBatteryManager alloc] init];
		[manager setMonitoring:NO];
		[manager probeBattery];
		
		print_battery([manager battery]);
		
		[manager release];
	}
	else if (NSLocationInRange(index, NSMakeRange(0, [LocalBatteryManager installedBatteries])))
	{		
		LocalBatteryManager *manager = [[LocalBatteryManager alloc] initWithIndex:index];
		[manager setMonitoring:NO];
		[manager probeBattery];

		print_battery([manager battery]);
		
		[manager release];
	}
	else
	{
		fprintf(stderr, "No such battery.\n");
	}
	[pool release];
	
	return EXIT_SUCCESS;
}
