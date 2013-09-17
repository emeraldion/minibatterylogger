//
//  Battery+ServerAdditions.m
//  MiniBatteryLogger
//
//  Created by delphine on 15-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "Battery+ServerAdditions.h"

const NSString *kMBLCapacityHeaderKey			= @"Capacity";
const NSString *kMBLMaxCapacityHeaderKey		= @"Max-Capacity";
const NSString *kMBLDesignCapacityHeaderKey		= @"Design-Capacity";
const NSString *kMBLCycleCountHeaderKey			= @"Cycle-Count";
const NSString *kMBLChargeHeaderKey				= @"Charge";
const NSString *kMBLTimeToEmptyHeaderKey		= @"Time-to-Empty";
const NSString *kMBLTimeToFullHeaderKey			= @"Time-to-Full";
const NSString *kMBLInstalledHeaderKey			= @"Installed";
const NSString *kMBLChargingHeaderKey			= @"Charging";
const NSString *kMBLPluggedHeaderKey			= @"Plugged";
const NSString *kMBLAmperageHeaderKey			= @"Amperage";
const NSString *kMBLVoltageHeaderKey			= @"Voltage";
const NSString *kMBLManufacturerHeaderKey		= @"Manufacturer";
const NSString *kMBLSerialHeaderKey				= @"Serial";
const NSString *kMBLManufactureDateHeaderKey	= @"Manufacture-Date";
const NSString *kMBLDeviceNameHeaderKey			= @"Device-Name";


@implementation Battery (ServerAdditions)

- (void)setPropertiesFromServerResponse:(NSString *)response
{
	NSScanner *responseScanner = [NSScanner scannerWithString:response];
	NSString *propName;
	
	while (![responseScanner isAtEnd])
	{
		if ([responseScanner scanUpToString:@":" intoString:&propName] &&
			[responseScanner scanString:@":" intoString:NULL])
		{			
			if ([[propName lowercaseString] isEqualToString:[kMBLSerialHeaderKey lowercaseString]])
			{
				NSString *serial;
				if ([responseScanner scanUpToString:@"\r\n" intoString:&serial])
				{
					[self setSerial:serial];
				}
			}			
			else if ([[propName lowercaseString] isEqualToString:[kMBLManufacturerHeaderKey lowercaseString]])
			{
				NSString *manufacturer;
				if ([responseScanner scanUpToString:@"\r\n" intoString:&manufacturer])
				{
					[self setManufacturer:manufacturer];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLDeviceNameHeaderKey lowercaseString]])
			{
				NSString *deviceName;
				if ([responseScanner scanUpToString:@"\r\n" intoString:&deviceName])
				{
					[self setDeviceName:deviceName];
				}
			}
			else if ([[propName lowercaseString] isEqualToString:[kMBLManufactureDateHeaderKey lowercaseString]])
			{
				NSString *manufactureDateStr;
				if ([responseScanner scanUpToString:@"\r\n" intoString:&manufactureDateStr])
				{
					NSCalendarDate *manufactureDate = [NSCalendarDate dateWithString:manufactureDateStr
																	  calendarFormat:@"%Y-%m-%d"];
					[self setManufactureDate:manufactureDate];
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
}

- (NSString *)capacityResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLCapacityHeaderKey, [self capacity]];
}

- (NSString *)cycleCountResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLCycleCountHeaderKey, [self cycleCount]];
}

- (NSString *)chargeResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLChargeHeaderKey, [self charge]];
}

- (NSString *)timeToEmptyResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLTimeToEmptyHeaderKey, (int)[self timeToEmpty]];
}

- (NSString *)timeToFullChargeResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLTimeToFullHeaderKey, (int)[self timeToFullCharge]];
}

- (NSString *)installedResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLInstalledHeaderKey, [self isInstalled] ? @"Yes" : @"No"];
}

- (NSString *)chargingResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLChargingHeaderKey, [self isCharging] ? @"Yes" : @"No"];
}

- (NSString *)pluggedResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLPluggedHeaderKey, [self isPlugged] ? @"Yes" : @"No"];
}

- (NSString *)amperageResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLAmperageHeaderKey, [self amperage]];
}

- (NSString *)voltageResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLVoltageHeaderKey, [self voltage]];
}

- (NSString *)maxCapacityResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLMaxCapacityHeaderKey, [self maxCapacity]];
}

- (NSString *)designCapacityResponseHeader
{
	return [NSString stringWithFormat:@"%@: %d\r\n", kMBLDesignCapacityHeaderKey, [self designCapacity]];
}

- (NSString *)manufacturerResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLManufacturerHeaderKey, [self manufacturer]];
}

- (NSString *)manufactureDateResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLManufactureDateHeaderKey, [[self manufactureDate] descriptionWithCalendarFormat:@"%Y-%m-%d"]];
}

- (NSString *)deviceNameResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLDeviceNameHeaderKey, [self deviceName]];
}

- (NSString *)serialResponseHeader
{
	return [NSString stringWithFormat:@"%@: %@\r\n", kMBLSerialHeaderKey, [self serial]];
}

@end
