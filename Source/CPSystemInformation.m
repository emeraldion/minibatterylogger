//
//  CPSystemInformation.m
//  MiniBatteryLogger
//
//  Created by delphine on 24-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//
//	Based upon Charles Parnot's CPSystemInformation class
//	<http://www.cocoadev.com/index.pl?HowToGetHardwareAndNetworkInfo>
//

#import "CPSystemInformation.h"

#import <Carbon/Carbon.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "NSData+MBLUtils.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetInterface.h>
#import <IOKit/network/IONetworkInterface.h>
#import <IOKit/network/IOEthernetController.h>

@implementation CPSystemInformation

//get everything!
+ (NSDictionary *)miniSystemProfile
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
		[self machineType],@"MachineType",
		[self humanMachineType],@"HumanMachineType",
		[self powerPCTypeString],@"ProcessorType",
		[NSNumber numberWithLong:
			[self processorClockSpeed]],
		@"ProcessorClockSpeed",
		[NSNumber numberWithLong:
			[self processorClockSpeedInMHz]],
		@"ProcessorClockSpeedInMHz",
		[NSNumber numberWithInt:[self countProcessors]],
		@"CountProcessors",
		[self computerName],@"ComputerName",
		[self computerSerialNumber],@"ComputerSerialNumber",
		[self operatingSystemString],@"OperatingSystem",
		[self systemVersionString],@"SystemVersion",		
		nil];
}


#pragma mark *** Getting the Human Name for the Machine Type ***

/* adapted from http://nilzero.com/cgi-bin/mt-comments.cgi?entry_id=1300 */
/*see below 'humanMachineNameFromNilZeroCom()' for the original code */
/*this code used a dictionary insted - see 'translationDictionary()' below */

//non-human readable machine type/model
+ (NSString *)machineType
{
	OSErr err;
	long *machineName=NULL;
	//gestaltUserVisibleMachineName = 'mnam'
	err = Gestalt(gestaltUserVisibleMachineName, &machineName);
	if (err==nil)
		return [NSString stringWithCString:(char *)machineName];
	else
		return @"machineType: machine name cannot be determined";
}

//dictionary used to make the machine type human-readable
static NSDictionary *translationDictionary=nil;
+ (NSDictionary *)translationDictionary
{
	if (translationDictionary==nil)
	{
		NSString *path = [[NSBundle mainBundle] pathForResource:@"hardwarenames" ofType:@"plist"];
		translationDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
		/*
		 translationDictionary=[[NSDictionary alloc] initWithObjectsAndKeys:
			 @"PowerMac 8500/8600",@"AAPL,8500",
			 @"PowerMac 9500/9600",@"AAPL,9500",
			 @"PowerMac 7200",@"AAPL,7200",
			 @"PowerMac 7200/7300",@"AAPL,7300",
			 @"PowerMac 7500",@"AAPL,7500",
			 @"Apple Network Server",@"AAPL,ShinerESB",
			 @"Alchemy(Performa 6400 logic-board design)",@"AAPL,e407",
			 @"Gazelle(5500)",@"AAPL,e411",
			 @"PowerBook 3400",@"AAPL,3400/2400",
			 @"PowerBook 3500",@"AAPL,3500",
			 @"PowerMac G3 (Gossamer)",@"AAPL,Gossamer",
			 @"PowerMac G3 (Silk)",@"AAPL,PowerMac G3",
			 @"PowerBook G3 (Wallstreet)",@"AAPL,PowerBook1998",
			 @"Yikes! Old machine - unknown model",@"AAPL",
			 
			 @"iMac (first generation)",@"iMac,1",
			 @"iMac (first generation) - unknown model",@"iMac",
			 
			 @"PowerBook G3 (Lombard)",@"PowerBook1,1",
			 @"iBook (clamshell)",@"PowerBook2,1",
			 @"iBook FireWire (clamshell)",@"PowerBook2,2",
			 @"PowerBook G3 (Pismo)",@"PowerBook3,1",
			 @"PowerBook G4 (Titanium)",@"PowerBook3,2",
			 @"PowerBook G4 (Titanium w/ Gigabit Ethernet)",
			 @"PowerBook3,3",
			 @"PowerBook G4 (Titanium w/ DVI)",@"PowerBook3,4",
			 @"PowerBook G4 (Titanium 1GHZ)",@"PowerBook3,5",
			 @"iBook (12in May 2001)",@"PowerBook4,1",
			 @"iBook (May 2002)",@"PowerBook4,2",
			 @"iBook 2 rev. 2 (w/ or w/o 14in LCD) (Nov 2002)",
			 @"PowerBook4,3",
			 @"iBook 2 (w/ or w/o 14in LDC)",@"PowerBook4,4",
			 @"PowerBook G4 (Aluminum 17in)",@"PowerBook5,1",
			 @"PowerBook G4 (Aluminum 15in)",@"PowerBook5,2",
			 @"PowerBook G4 (Aluminum 17in rev. 2)",@"PowerBook5,3",
			 @"PowerBook G4 (Aluminum 12in)",@"PowerBook6,1",
			 @"PowerBook G4 (Aluminum 12in)",@"PowerBook6,2",
			 @"iBook G4",@"PowerBook6,3",
			 @"PowerBook or iBook - unknown model",@"PowerBook",
			 
			 @"Blue & White G3",@"PowerMac1,1",
			 @"PowerMac G4 PCI Graphics",@"PowerMac1,2",
			 @"iMac FireWire (CRT)",@"PowerMac2,1",
			 @"iMac FireWire (CRT)",@"PowerMac2,2",
			 @"PowerMac G4 AGP Graphics",@"PowerMac3,1",
			 @"PowerMac G4 AGP Graphics",@"PowerMac3,2",
			 @"PowerMac G4 AGP Graphics",@"PowerMac3,3",
			 @"PowerMac G4 (QuickSilver)",@"PowerMac3,4",
			 @"PowerMac G4 (QuickSilver)",@"PowerMac3,5",
			 @"PowerMac G4 (MDD/Windtunnel)",@"PowerMac3,6",
			 @"iMac (Flower Power)",@"PowerMac4,1",
			 @"iMac (Flat Panel 15in)",@"PowerMac4,2",
			 @"eMac",@"PowerMac4,4",
			 @"iMac (Flat Panel 17in)",@"PowerMac4,5",
			 @"PowerMac G4 Cube",@"PowerMac5,1",
			 @"PowerMac G4 Cube",@"PowerMac5,2",
			 @"iMac (Flat Panel 17in)",@"PowerMac6,1",
			 @"PowerMac G5",@"PowerMac7,2",
			 @"PowerMac G5",@"PowerMac7,3",
			 @"PowerMac - unknown model",@"PowerMac",
			 
			 @"XServe",@"RackMac1,1",
			 @"XServe rev. 2",@"RackMac1,2",
			 @"XServe G5",@"RackMac3,1",
			 @"XServe - unknown model",@"RackMac",
			 
			 nil];
		 */
	}
	return translationDictionary;
}

+ (id)humanMachineType
{
	return [self humanMachineTypeForMachine:[self machineType]];
}
	
+ (id)humanMachineTypeForMachine:(NSString *)machineType
{
	NSString *human=nil;
		
	//return the corresponding entry in the NSDictionary
	NSDictionary *translation=[self translationDictionary];
	NSString *aKey;
	//keys should be sorted to distinguish 'generic' from 'specific' names
	NSEnumerator *e=[[[translation allKeys]
					sortedArrayUsingSelector:@selector(compare:)]
		objectEnumerator];
	NSRange r;
	while (aKey=[e nextObject]) {
		r=[machineType rangeOfString:aKey];
		if (r.location!=NSNotFound)
			//continue searching : the first hit will be the generic name
			human=[translation objectForKey:aKey];
	}
	if (human)
		return human;
	else
		return machineType;
}

//for some reason, this does not work
//probably old stuff still around
+ (NSString *)humanMachineTypeAlternate
{
	OSErr err;
	long result;
	Str255 name;
	err=Gestalt('mach',&result); //gestaltMachineType = 'mach'
	if (err==nil) {
		GetIndString(name,kMachineNameStrID,(short)result);
		return [NSString stringWithCString:name];
	} else
		return @"humanMachineTypeAlternate: machine name cannot be determined";
}


#pragma mark *** Getting Processor info ***

+ (long)processorClockSpeed
{
	OSErr err;
	long result;
	err=Gestalt(gestaltProcClkSpeed,&result);
	if (err!=nil)
		return 0;
	else
		return result;
}

+ (long)processorClockSpeedInMHz
{
	return [self processorClockSpeed]/1000000;
}

#include <mach/mach_host.h>
#include <mach/host_info.h>
+ (unsigned int)countProcessors
{
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount;
	
	infoCount = HOST_BASIC_INFO_COUNT;
	host_info(mach_host_self(), HOST_BASIC_INFO, 
			  (host_info_t)&hostInfo, &infoCount);
	
	return (unsigned int)(hostInfo.max_cpus);
	
}

#include <mach/mach.h>
#include <mach/machine.h>


// the following methods were more or less copied from
//	http://developer.apple.com/technotes/tn/tn2086.html
//	http://www.cocoadev.com/index.pl?GettingTheProcessor
//	and can be better understood with a look at
//	file:///usr/include/mach/machine.h

+ (BOOL) isPowerPC
{
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount;
	
	infoCount = HOST_BASIC_INFO_COUNT;
	kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO,
								  (host_info_t)&hostInfo, &infoCount);
	
	return ( (KERN_SUCCESS == ret) &&
			 (hostInfo.cpu_type == CPU_TYPE_POWERPC) );
}

+ (BOOL) isG3
{
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount;
	
	infoCount = HOST_BASIC_INFO_COUNT;
	kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO,
								  (host_info_t)&hostInfo, &infoCount);
	
	return ( (KERN_SUCCESS == ret) &&
			 (hostInfo.cpu_type == CPU_TYPE_POWERPC) &&
			 (hostInfo.cpu_subtype == CPU_SUBTYPE_POWERPC_750) );
}

+ (BOOL) isG4
{
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount;
	
	infoCount = HOST_BASIC_INFO_COUNT;
	kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO,
								  (host_info_t)&hostInfo, &infoCount);
	
	return ( (KERN_SUCCESS == ret) &&
			 (hostInfo.cpu_type == CPU_TYPE_POWERPC) &&
			 (hostInfo.cpu_subtype == CPU_SUBTYPE_POWERPC_7400 ||
			  hostInfo.cpu_subtype == CPU_SUBTYPE_POWERPC_7450));
}

#ifndef CPU_SUBTYPE_POWERPC_970
#define CPU_SUBTYPE_POWERPC_970 ((cpu_subtype_t) 100)
#endif
+ (BOOL) isG5
{
	host_basic_info_data_t hostInfo;
	mach_msg_type_number_t infoCount;
	
	infoCount = HOST_BASIC_INFO_COUNT;
	kern_return_t ret = host_info(mach_host_self(), HOST_BASIC_INFO,
								  (host_info_t)&hostInfo, &infoCount);
	
	return ( (KERN_SUCCESS == ret) &&
			 (hostInfo.cpu_type == CPU_TYPE_POWERPC) &&
			 (hostInfo.cpu_subtype == CPU_SUBTYPE_POWERPC_970));
}	

+ (NSString *)powerPCTypeString
{
	if ([self isG3])
		return @"G3";
	else if ([self isG4])
		return @"G4";
	else if ([self isG5])
		return @"G5";
	else if ([self isPowerPC])
		return @"PowerPC pre-G3";
	else
		return @"Non-PowerPC";
	
}

#pragma mark *** Machine information ***

//this used to be called 'Rendezvous name' (X.2), now just 'Computer name' (X.3)
//see here for why: http://developer.apple.com/qa/qa2001/qa1228.html
//this is the name set in the Sharing pref pane
+ (NSString *)computerName
{
	CFStringRef name;
	NSString *computerName;
	name=SCDynamicStoreCopyComputerName(NULL,NULL);
	computerName=[NSString stringWithString:(NSString *)name];
	CFRelease(name);
	return computerName;
}

/* copied from http://cocoa.mamasam.com/COCOADEV/2003/07/1/68334.php */
/* and modified by http://nilzero.com/cgi-bin/mt-comments.cgi?entry_id=1300 */
/* and by http://cocoa.mamasam.com/COCOADEV/2003/07/1/68337.php/ */
+ (NSString *)computerSerialNumber
{
	NSString         *result = @"";
	mach_port_t       masterPort;
	kern_return_t      kr = noErr;
	io_registry_entry_t  entry;    
	CFDataRef         propData;
	CFTypeRef         prop;
	CFTypeID         propID=NULL;
	UInt8           *data;
	unsigned int        i, bufSize;
	char            *s, *t;
	char            firstPart[64], secondPart[64];
	
	kr = IOMasterPort(MACH_PORT_NULL, &masterPort);        
	if (kr == noErr) {
		entry = IORegistryGetRootEntry(masterPort);
		if (entry != MACH_PORT_NULL) {
			prop = IORegistryEntrySearchCFProperty(entry,
												   kIODeviceTreePlane,
												   CFSTR("serial-number"),
												   nil, kIORegistryIterateRecursively);
			if (prop == nil) {
				result = @"null";
			} else {
				propID = CFGetTypeID(prop);
			}
			if (propID == CFDataGetTypeID()) {
				propData = (CFDataRef)prop;
				bufSize = CFDataGetLength(propData);
				if (bufSize > 0) {
					data = CFDataGetBytePtr(propData);
					if (data) {
						i = 0;
						s = data;
						t = firstPart;
						while (i < bufSize) {
							i++;
							if (*s != '\0') {
								*t++ = *s++;
							} else {
								break;
							}
						}
						*t = '\0';
						
						while ((i < bufSize) && (*s == '\0')) {
							i++;
							s++;
						}
						
						t = secondPart;
						while (i < bufSize) {
							i++;
							if (*s != '\0') {
								*t++ = *s++;
							} else {
								break;
							}
						}
						*t = '\0';
						result =
							[NSString stringWithFormat:
								@"%s%s",secondPart,firstPart];
					}
				}
			}
		}
		mach_port_deallocate(mach_task_self(), masterPort);
	}
	return(result);
}

#pragma mark *** System version ***

+ (NSString *)operatingSystemString
{
	NSProcessInfo *procInfo = [NSProcessInfo processInfo];
	return [procInfo operatingSystemName];
}

+ (NSString *)systemVersionString
{
	NSProcessInfo *procInfo = [NSProcessInfo processInfo];
	return [procInfo operatingSystemVersionString];
}

#pragma mark === MAC Address ===

static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices);
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize);

// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
static kern_return_t FindEthernetInterfaces(io_iterator_t *matchingServices)
{
    kern_return_t    kernResult; 
    CFMutableDictionaryRef  matchingDict;
    CFMutableDictionaryRef  propertyMatchDict;
    
    // Ethernet interfaces are instances of class kIOEthernetInterfaceClass. 
    // IOServiceMatching is a convenience function to create a dictionary with the key kIOProviderClassKey and 
    // the specified value.
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);
	
    // Note that another option here would be:
    // matchingDict = IOBSDMatching("en0");
	
    if (NULL == matchingDict) {
        printf("IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
        // Each IONetworkInterface object has a Boolean property with the key kIOPrimaryInterface. Only the
        // primary (built-in) interface has this property set to TRUE.
        
        // IOServiceGetMatchingServices uses the default matching criteria defined by IOService. This considers
        // only the following properties plus any family-specific matching in this order of precedence 
        // (see IOService::passiveMatch):
        //
        // kIOProviderClassKey (IOServiceMatching)
        // kIONameMatchKey (IOServiceNameMatching)
        // kIOPropertyMatchKey
        // kIOPathMatchKey
        // kIOMatchedServiceCountKey
        // family-specific matching
        // kIOBSDNameKey (IOBSDNameMatching)
        // kIOLocationMatchKey
        
        // The IONetworkingFamily does not define any family-specific matching. This means that in            
        // order to have IOServiceGetMatchingServices consider the kIOPrimaryInterface property, we must
        // add that property to a separate dictionary and then add that to our matching dictionary
        // specifying kIOPropertyMatchKey.
		
        propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
													  &kCFTypeDictionaryKeyCallBacks,
													  &kCFTypeDictionaryValueCallBacks);
		
        if (NULL == propertyMatchDict) {
            printf("CFDictionaryCreateMutable returned a NULL dictionary.\n");
        }
        else {
            // Set the value in the dictionary of the property with the given key, or add the key 
            // to the dictionary if it doesn't exist. This call retains the value object passed in.
            CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue); 
            
            // Now add the dictionary containing the matching value for kIOPrimaryInterface to our main
            // matching dictionary. This call will retain propertyMatchDict, so we can release our reference 
            // on propertyMatchDict after adding it to matchingDict.
            CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
            CFRelease(propertyMatchDict);
        }
    }
    
    // IOServiceGetMatchingServices retains the returned iterator, so release the iterator when we're done with it.
    // IOServiceGetMatchingServices also consumes a reference on the matching dictionary so we don't need to release
    // the dictionary explicitly.
    kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, matchingServices);    
    if (KERN_SUCCESS != kernResult) {
        printf("IOServiceGetMatchingServices returned 0x%08x\n", kernResult);
    }
	
    return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.
static kern_return_t GetMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress, UInt8 bufferSize)
{
    io_object_t    intfService;
    io_object_t    controllerService;
    kern_return_t  kernResult = KERN_FAILURE;
    
    // Make sure the caller provided enough buffer space. Protect against buffer overflow problems.
	if (bufferSize < kIOEthernetAddressSize) {
		return kernResult;
	}
	
	// Initialize the returned address
    bzero(MACAddress, bufferSize);
    
    // IOIteratorNext retains the returned object, so release it when we're done with it.
    while (intfService = IOIteratorNext(intfIterator))
    {
        CFTypeRef  MACAddressAsCFData;        
		
        // IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call, 
        // since they are hardware nubs and do not participate in driver matching. In other words,
        // registerService() is never called on them. So we've found the IONetworkInterface and will 
        // get its parent controller by asking for it specifically.
        
        // IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
        kernResult = IORegistryEntryGetParentEntry(intfService,
												   kIOServicePlane,
												   &controllerService);
		
        if (KERN_SUCCESS != kernResult) {
            printf("IORegistryEntryGetParentEntry returned 0x%08x\n", kernResult);
        }
        else {
            // Retrieve the MAC address property from the I/O Registry in the form of a CFData
            MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService,
																 CFSTR(kIOMACAddress),
																 kCFAllocatorDefault,
																 0);
            if (MACAddressAsCFData) {
                //CFShow(MACAddressAsCFData); // for display purposes only; output goes to stderr
                
                // Get the raw bytes of the MAC address from the CFData
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
                CFRelease(MACAddressAsCFData);
            }
			
            // Done with the parent Ethernet controller object so we release it.
            (void) IOObjectRelease(controllerService);
        }
        
        // Done with the Ethernet interface object so we release it.
        (void) IOObjectRelease(intfService);
    }
	
    return kernResult;
}

+ (NSString *)mainMACAddress
{
	kern_return_t	kernResult = KERN_SUCCESS;
	io_iterator_t	intfIterator;
	UInt8			MACAddress[kIOEthernetAddressSize];
	NSString		*string = nil;

	kernResult = FindEthernetInterfaces(&intfIterator);

	if (KERN_SUCCESS != kernResult)
	{
		//printf("FindEthernetInterfaces returned 0x%08x\n", kernResult);
		string =[NSString stringWithString:@"000000000000"];
	}
	else
	{
		kernResult = GetMACAddress(intfIterator, MACAddress, sizeof(MACAddress));
		
		if (KERN_SUCCESS != kernResult)
		{
			string =[NSString stringWithString:@"000000000000"];
		}
		else
		{            
			string = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x",
					MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3],  
					MACAddress[4], MACAddress[5]];
		}
	}
	(void) IOObjectRelease(intfIterator);            // Release the iterator.
	return string;
}

+ (NSString *)systemUniqueID
{
	// Simply return the MD5 of the main MAC Address + the system serial number
	NSString *clear = [NSString stringWithFormat:@"%@%@",
		[self mainMACAddress], [self computerSerialNumber]];
	
	return [[clear dataUsingEncoding:NSUTF8StringEncoding] md5HashAsString];
}

@end