//
//  DifferentialBatteryUnitTest.h
//  MiniBatteryLogger
//
//  Created by delphine on 17-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "DifferentialBattery.h"

@interface DifferentialBatteryUnitTest : SenTestCase {
	DifferentialBattery *diff;
}

- (void)testCreation;
- (void)testCapacity;
- (void)testCycleCount;
- (void)testVoltage;
- (void)testDifferentialBatteryAdditions;

@end
