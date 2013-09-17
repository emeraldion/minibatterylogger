//
//  Battery+XML.m
//  MiniBatteryLogger
//
//  Created by delphine on 14-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "Battery+XML.h"


@implementation Battery (XML)

- (NSString *)xmlDescription
{
	return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\
<battery xmlns=\"http://burgos.emeraldion.it/mbl/\">\n\
	<charge>%d</charge>\n\
	<capacity>%d</capacity>\n\
	<maxCapacity>%d</maxCapacity>\n\
	<designCapacity>%d</designCapacity>\n\
	<voltage>%d</voltage>\n\
	<amperage>%d</amperage>\n\
	<cycleCount>%d</cycleCount>\n\
	<plugged>%d</plugged>\n\
	<charging>%d</charging>\n\
	<timeToEmpty>%.0f</timeToEmpty>\n\
	<timeToFullCharge>%.0f</timeToFullCharge>\n\
	<manufacturer>%@</manufacturer>\n\
	<manufactureDate>%@</manufactureDate>\n\
	<deviceName>%@</deviceName>\n\
	<serialNumber>%@</serialNumber>\n\
</battery>",
		[self charge],
		[self capacity],
		[self maxCapacity],
		[self designCapacity],
		[self voltage],
		[self amperage],
		[self cycleCount],
		[self isPlugged],
		[self isCharging],
		[self timeToEmpty],
		[self timeToFullCharge],
		[self manufacturer],
		[[self manufactureDate] descriptionWithCalendarFormat:@"%Y-%m-%d"],
		[self deviceName],
		[self serial]];					   
}

@end
