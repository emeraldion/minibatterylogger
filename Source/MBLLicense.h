//
//  MBLLicense.h
//  MiniBatteryLogger
//
//  Created by delphine on 17-08-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <openssl/pem.h>
#import <openssl/rsa.h>
#import <openssl/bio.h>
#import "NSData+MBLUtils.h"
#import "base32.h"
#import "GSNSDataExtensions.h"

/*!
 @enum MBLLicenseType
 @abstract Defines the possible license types for a MiniBatteryLogger license.
 */
typedef enum {
	MBLSingleUserLicenseType = 0,
	MBLFamilyPackLicenseType,
	MBLSiteLicenseType,
	MBLEvaluationLicenseType,
	MBLGiftLicenseType
} MBLLicenseType;

@interface MBLLicense : NSObject <NSCoding> {
	
	NSString *_username;
	NSString *_hash;
	NSCalendarDate *_startDate;
	NSCalendarDate *_expirationDate;
	MBLLicenseType _licenseType;
}

+ (NSString *)descriptionForLicenseType:(MBLLicenseType)type;
+ (id)licenseForUsername:(NSString *)username key:(NSString *)key;
+ (int)minKeyLength;

- (MBLLicenseType)licenseType;
- (NSCalendarDate *)startDate;
- (NSCalendarDate *)expirationDate;
- (NSString *)username;
- (NSString *)hash;

- (void)setStartDate:(NSCalendarDate *)date;
- (void)setExpirationDate:(NSCalendarDate *)date;
- (void)setHash:(NSString *)hash;
- (void)setUsername:(NSString *)username;
- (void)setLicenseType:(MBLLicenseType)type;

- (BOOL)isValid;
- (id)initWithUsername:(NSString *)username key:(NSString *)key;

@end
