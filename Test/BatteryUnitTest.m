//
//  BatteryUnitTest.m
//  MiniBatteryLogger
//
//  Created by delphine on 16-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "BatteryUnitTest.h"


@implementation BatteryUnitTest

- (void)setUp
{
}

- (void)tearDown
{
}

- (void)testCreation
{
	Battery *batt = [Battery battery];
	STAssertNotNil(batt, @"Battery was nil");

	STAssertFalse([batt isCharging], @"Battery is not charging");
	STAssertFalse([batt isPlugged], @"Battery is not plugged");
	
	STAssertEquals([batt charge], 0, @"Charge is zero");
	STAssertEquals([batt capacity], 0, @"Charge is zero");
	STAssertEquals([batt maxCapacity], 0, @"Max capacity is zero");
	STAssertEquals([batt absoluteMaxCapacity], 0, @"Absolute max capacity is zero");
	STAssertEquals([batt cycleCount], 0, @"Cycle count is zero");
	STAssertEquals([batt amperage], 0, @"Amperage is zero");
}

- (void)testCharge
{
	Battery *batt = [Battery battery];

	STAssertEquals([batt charge], 0, @"Wrong charge");
	
	[batt setCharge:33];
	STAssertEquals([batt charge], 33, @"Wrong charge");

	[batt setCharge:-12];
	STAssertEquals([batt charge], 0, @"Wrong charge");

	[batt setCharge:150];
	STAssertEquals([batt charge], 100, @"Wrong charge");
}

- (void)testCapacity
{
	Battery *batt = [Battery battery];
	
	STAssertEquals([batt capacity], 0, @"Wrong capacity");
	
	[batt setCapacity:1200];
	STAssertEquals([batt capacity], 1200, @"Wrong capacity");
	
	[batt setCapacity:-150];
	STAssertEquals([batt capacity], 0, @"Wrong capacity");	
}

- (void)testAmperage
{
	Battery *batt = [Battery battery];
	
	STAssertEquals([batt amperage], 0, @"Wrong amperage");
	
	[batt setAmperage:500];
	STAssertEquals([batt amperage], 500, @"Wrong amperage");	
	STAssertEquals([batt peakAmperage], 500, @"Wrong peak amperage");

	[batt setAmperage:800];
	STAssertEquals([batt amperage], 800, @"Wrong amperage");	
	STAssertEquals([batt peakAmperage], 800, @"Wrong peak amperage");

	[batt setAmperage:100];
	STAssertEquals([batt amperage], 100, @"Wrong amperage");	
	STAssertEquals([batt peakAmperage], 800, @"Wrong peak amperage");

	[batt setAmperage:-1200];
	STAssertEquals([batt amperage], -1200, @"Wrong amperage");
}

- (void)testVoltage
{
	Battery *batt = [Battery battery];
	
	STAssertEquals([batt voltage], 0, @"Wrong voltage");
	
	[batt setVoltage:12000];
	STAssertEquals([batt voltage], 12000, @"Wrong voltage");
	
	[batt setVoltage:-12000];
	STAssertEquals([batt voltage], 0, @"Wrong voltage");
}

- (void)testCycleCount
{
	Battery *batt = [Battery battery];
	
	STAssertEquals([batt cycleCount], 0, @"Wrong cycle count");
	
	[batt setCycleCount:500];
	STAssertEquals([batt cycleCount], 500, @"Wrong cycle count");
	
	[batt setCycleCount:-1200];
	STAssertEquals([batt cycleCount], 0, @"Wrong cycle count");
}

- (void)testIsCharging
{
	Battery *batt = [Battery battery];
	STAssertFalse([batt isCharging], @"Battery is not charging");

	[batt setCharging:YES];
	STAssertTrue([batt isCharging], @"Battery is charging");
}

- (void)testIsPlugged
{
	Battery *batt = [Battery battery];
	STAssertFalse([batt isPlugged], @"Battery is plugged");
	
	[batt setPlugged:YES];
	STAssertTrue([batt isPlugged], @"Battery is not plugged");
}

- (void)testBatteryTimer
{
	Battery *batt = [Battery battery];
	STAssertEquals([batt timeOnBattery], 0.0, @"Time on battery is zero");
	[batt incrementTimeOnBattery];
	STAssertEquals([batt timeOnBattery], 60.0, @"Wrong time on battery");
}

@end
