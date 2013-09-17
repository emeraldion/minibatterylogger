//
//  BatteryUnitTest.h
//  MiniBatteryLogger
//
//  Created by delphine on 16-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Battery.h"

@interface BatteryUnitTest : SenTestCase {

}

- (void)testCreation;

- (void)testCharge;
- (void)testCapacity;
- (void)testAmperage;
- (void)testVoltage;
- (void)testCycleCount;

- (void)testIsCharging;
- (void)testIsPlugged;

- (void)testBatteryTimer;

@end
