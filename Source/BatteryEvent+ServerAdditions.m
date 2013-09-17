//
//  BatteryEvent+ServerAdditions.m
//  MiniBatteryLogger
//
//  Created by delphine on 16-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatteryEvent+ServerAdditions.h"

@interface BatteryEvent (ServerAdditions_Private)

- (NSDictionary *)_dictionaryFromServerResponse:(NSString *)response;

@end

@implementation BatteryEvent (ServerAdditions)

+ (id)batteryEventWithServerResponse:(NSString *)response
{
	return [[[self alloc] initWithServerResponse:response] autorelease];
}

- (id)initWithServerResponse:(NSString *)response
{
	if (self = [super init])
	{
		[self setDate:[NSCalendarDate date]];
		[self setDetails:[self _dictionaryFromServerResponse:response]];
	}
	return self;
}

@end

@implementation BatteryEvent (ServerAdditions_Private)

- (NSDictionary *)_dictionaryFromServerResponse:(NSString *)response
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSScanner *responseScanner = [NSScanner scannerWithString:response];
	NSString *propName;

	while (![responseScanner isAtEnd])
	{
		if ([responseScanner scanUpToString:@":" intoString:&propName] &&
			[responseScanner scanString:@":" intoString:NULL])
		{
			//NSLog(@"propName:%@", propName);
			
			if ([[propName lowercaseString] isEqualToString:[kMBLChargeHeaderKey lowercaseString]])
			{
				int charge;
				if ([responseScanner scanInt:&charge])
				{
					//NSLog(@"charge:%d", charge);
					[dict setObject:[NSNumber numberWithInt:charge]
							 forKey:kMBLChargeKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLCapacityHeaderKey lowercaseString]])
			{
				int capacity;
				if ([responseScanner scanInt:&capacity])
				{
					//NSLog(@"capacity:%d", capacity);
					[dict setObject:[NSNumber numberWithInt:capacity]
							 forKey:kMBLCapacityKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLCycleCountHeaderKey lowercaseString]])
			{
				int cycles;
				if ([responseScanner scanInt:&cycles])
				{
					//NSLog(@"cycles:%d", cycles);
					[dict setObject:[NSNumber numberWithInt:cycles]
							 forKey:kMBLCycleCountKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLMaxCapacityHeaderKey lowercaseString]])
			{
				int maxCapacity;
				if ([responseScanner scanInt:&maxCapacity])
				{
					//NSLog(@"maxCapacity:%d", maxCapacity);
					[dict setObject:[NSNumber numberWithInt:maxCapacity]
							 forKey:kMBLMaxCapacityKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLMaxCapacityHeaderKey lowercaseString]])
			{
				int maxCapacity;
				if ([responseScanner scanInt:&maxCapacity])
				{
					//NSLog(@"maxCapacity:%d", maxCapacity);
					[dict setObject:[NSNumber numberWithInt:maxCapacity]
							 forKey:kMBLMaxCapacityKey];
				}
			}			
			else if ([[propName lowercaseString] isEqualToString:[kMBLDesignCapacityHeaderKey lowercaseString]])
			{
				int design_capacity;
				if ([responseScanner scanInt:&design_capacity])
				{
					//NSLog(@"design_capacity:%d", design_capacity);
					[dict setObject:[NSNumber numberWithInt:design_capacity]
							 forKey:kMBLDesignCapacityKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLVoltageHeaderKey lowercaseString]])
			{
				int voltage;
				if ([responseScanner scanInt:&voltage])
				{
					//NSLog(@"voltage:%d", voltage);
					[dict setObject:[NSNumber numberWithInt:voltage]
							 forKey:kMBLVoltageKey];
				}				
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLAmperageHeaderKey lowercaseString]])
			{
				int amperage;
				if ([responseScanner scanInt:&amperage])
				{
					//NSLog(@"amperage:%d", amperage);
					[dict setObject:[NSNumber numberWithInt:amperage]
							 forKey:kMBLAmperageKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLTimeToFullHeaderKey lowercaseString]])
			{
				int timeToFull;
				if ([responseScanner scanInt:&timeToFull])
				{
					//NSLog(@"timeToFull:%d", timeToFull);
					// This value must be converted in minutes
					[dict setObject:[NSNumber numberWithInt:timeToFull / 60]
							 forKey:kMBLTimeToFullKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLTimeToEmptyHeaderKey lowercaseString]])
			{
				int timeToEmpty;
				if ([responseScanner scanInt:&timeToEmpty])
				{
					//NSLog(@"timeToEmpty:%d", timeToEmpty);
					// This value must be converted in minutes
					[dict setObject:[NSNumber numberWithInt:timeToEmpty / 60]
							 forKey:kMBLTimeToEmptyKey];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLChargingHeaderKey lowercaseString]])
			{
				NSString *is_charging;
				BOOL charging = NO;
				if ([responseScanner scanUpToString:@"\r\n" intoString:&is_charging])
				{
					if ([[is_charging lowercaseString] isEqualToString:@"yes"])
					{
						charging = YES;
					}
					//NSLog(@"charging:%d", charging);
					[dict setObject:[NSNumber numberWithBool:charging]
							 forKey:kMBLChargingKey];
				}
			}			
			else if ([[propName lowercaseString] isEqualToString:[kMBLPluggedHeaderKey lowercaseString]])
			{
				//NSLog(@"propName:%@", propName);
				NSString *is_plugged;
				BOOL plugged = NO;
				if ([responseScanner scanUpToString:@"\r\n" intoString:&is_plugged])
				{
					//NSLog(@"is_plugged:%@", is_plugged);
					if ([[is_plugged lowercaseString] isEqualToString:@"yes"])
					{
						plugged = YES;
					}
					//NSLog(@"plugged:%d", plugged);
					[dict setObject:plugged ? kMBLPowerSourceACValue : kMBLPowerSourceBatteryValue
							 forKey:kMBLPowerSourceStateKey];
				}
			}
			else
			{
				NSString *garbage;
				[responseScanner scanUpToString:@"\r\n" intoString:&garbage];
				//NSLog(@"Discarding <%@>", garbage);
			}
			[responseScanner scanString:@"\r\n" intoString:NULL];
		}
	}
	return dict;
}

@end