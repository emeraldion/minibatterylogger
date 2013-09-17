//
//  CPSystemInformation.h
//  MiniBatteryLogger
//
//  Created by delphine on 24-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//
//	Based upon Charles Parnot's CPSystemInformation class
//	<http://www.cocoadev.com/index.pl?HowToGetHardwareAndNetworkInfo>
//

#import <Cocoa/Cocoa.h>


@interface CPSystemInformation : NSObject {}

//all the info at once!
+ (NSDictionary *)miniSystemProfile;

+ (NSString *)machineType;
// This method returns a NSArray in case of ambiguity, an NSString otherwise.
+ (id)humanMachineType;
+ (id)humanMachineTypeForMachine:(NSString *)machine;
+ (NSString *)humanMachineTypeAlternate;

+ (long)processorClockSpeed;
+ (long)processorClockSpeedInMHz;
+ (unsigned int)countProcessors;
+ (BOOL) isPowerPC;
+ (BOOL) isG3;
+ (BOOL) isG4;
+ (BOOL) isG5;
//+ (BOOL) isIntel;
+ (NSString *)powerPCTypeString;

+ (NSString *)computerName;
+ (NSString *)computerSerialNumber;

+ (NSString *)operatingSystemString;
+ (NSString *)systemVersionString;

+ (NSString *)mainMACAddress;
+ (NSString *)systemUniqueID;

@end