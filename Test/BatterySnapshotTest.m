//
//  BatterySnapshotTest.m
//  MiniBatteryLogger
//
//  Created by delphine on 13-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatterySnapshotTest.h"


@implementation BatterySnapshotTest

- (void)testIsEqual
{
	Battery *batt1 = [Battery battery];
	[batt1 setMaxCapacity:1000];

	Battery *batt2 = [Battery battery];
	[batt2 setMaxCapacity:1000];

	Battery *batt3 = [Battery battery];
	[batt3 setMaxCapacity:2000];
	
	NSString *comm1 = @"Gut";
	NSString *comm2 = @"Gut";
	NSString *comm3 = @"Awful";

	NSCalendarDate *date1 = [NSCalendarDate dateWithString:@"2008-06-12"
											calendarFormat:@"%Y-%m-%d"];
	
	NSCalendarDate *date2 = [NSCalendarDate dateWithString:@"2008-06-12"
											calendarFormat:@"%Y-%m-%d"];
	
	NSCalendarDate *date3 = [NSCalendarDate dateWithString:@"2008-05-23"
											calendarFormat:@"%Y-%m-%d"];
	
	BatterySnapshot *shot1 = [[BatterySnapshot alloc] initWithBattery:batt1
																 date:date1];
	[shot1 setComment:comm1];

	BatterySnapshot *shot2 = [[BatterySnapshot alloc] initWithBattery:batt2
																 date:date2];
	[shot2 setComment:comm2];

	BatterySnapshot *shot3 = [[BatterySnapshot alloc] initWithBattery:batt3
																 date:date3];
	[shot3 setComment:comm3];
	
	STAssertTrue([shot1 isEqual:shot2], @"Snapshots should be equal");
	STAssertTrue([shot2 isEqual:shot1], @"Snapshots should be equal");
	STAssertEqualObjects(shot1, shot2, @"Snapshots should be equal");
	STAssertEqualObjects(shot2, shot1, @"Snapshots should be equal");

	STAssertFalse([shot1 isEqual:shot3], @"Snapshots should not be equal");
	STAssertFalse([shot2 isEqual:shot3], @"Snapshots should not be equal");
	STAssertFalse([shot3 isEqual:shot1], @"Snapshots should not be equal");
	STAssertFalse([shot3 isEqual:shot2], @"Snapshots should not be equal");
	
	[shot1 release];
	[shot2 release];
	[shot3 release];
}

- (void)testFactoryMethod
{
	BatterySnapshot *shot = [BatterySnapshot snapshot];
	STAssertTrue([shot isMemberOfClass:[BatterySnapshot class]], @"Wrong class");
}

@end
