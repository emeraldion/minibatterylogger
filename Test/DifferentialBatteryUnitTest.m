//
//  DifferentialBatteryUnitTest.m
//  MiniBatteryLogger
//
//  Created by delphine on 17-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "DifferentialBatteryUnitTest.h"


@implementation DifferentialBatteryUnitTest

- (void)setUp
{
	diff = [[DifferentialBattery alloc] init];
}

- (void)tearDown
{
	[diff release];
}

- (void)testCreation
{
	DifferentialBattery *batt = [DifferentialBattery battery];
	STAssertNotNil(batt, @"Expected not nil");
}

- (void)testCapacity
{
	[diff setCapacity:100];
	STAssertEquals([diff capacity], 100, @"Bad capacity");

	[diff setCapacity:-100];
	STAssertEquals([diff capacity], -100, @"Bad capacity");

	[diff setMaxCapacity:100];
	STAssertEquals([diff maxCapacity], 100, @"Bad max capacity");
	
	[diff setMaxCapacity:-100];
	STAssertEquals([diff maxCapacity], -100, @"Bad max capacity");

	[diff setAbsoluteMaxCapacity:100];
	STAssertEquals([diff absoluteMaxCapacity], 100, @"Bad absolute max capacity");
	
	[diff setAbsoluteMaxCapacity:-100];
	STAssertEquals([diff absoluteMaxCapacity], -100, @"Bad absolute max capacity");	
}

- (void)testCycleCount
{
	[diff setCycleCount:100];
	STAssertEquals([diff cycleCount], 100, @"Bad cycles");
	
	[diff setCycleCount:-100];
	STAssertEquals([diff cycleCount], -100, @"Bad cycles");	
}

- (void)testVoltage
{
	[diff setVoltage:100];
	STAssertEquals([diff voltage], 100, @"Bad voltage");
	
	[diff setVoltage:-100];
	STAssertEquals([diff voltage], -100, @"Bad voltage");	
}

- (void)testDifferentialBatteryAdditions
{
	Battery *batt1 = [Battery battery];
	[batt1 setCharge:100];
	[batt1 setCapacity:4400];
	[batt1 setMaxCapacity:4400];
	[batt1 setAbsoluteMaxCapacity:4400];
	[batt1 setCycleCount:200];
	[batt1 setVoltage:12000];
	[batt1 setAmperage:-2000];

	Battery *batt2 = [Battery battery];
	[batt2 setCharge:25];
	[batt2 setCapacity:1000];
	[batt2 setMaxCapacity:4000];
	[batt2 setAbsoluteMaxCapacity:4400];
	[batt2 setCycleCount:600];
	[batt2 setVoltage:10000];
	[batt2 setAmperage:1000];
	
	DifferentialBattery *differential = [batt1 differentialBattery:batt2];
	
	STAssertEquals([differential charge], 75, @"Bad charge");
	STAssertEquals([differential capacity], 3400, @"Bad capacity");
	STAssertEquals([differential maxCapacity], 400, @"Bad max capacity");
	STAssertEquals([differential absoluteMaxCapacity], 0, @"Bad absolute max capacity");
	STAssertEquals([differential voltage], 2000, @"Bad voltage");
	STAssertEquals([differential amperage], -3000, @"Bad amperage");
	STAssertEquals([differential cycleCount], -400, @"Bad cycles");
}

@end
