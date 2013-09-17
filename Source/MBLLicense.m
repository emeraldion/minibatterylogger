//
//  MBLLicense.m
//  MiniBatteryLogger
//
//  Created by delphine on 17-08-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLLicense.h"

static int MBLLicenseMinKeyLength = 16;

@implementation MBLLicense

- (void)dealloc
{
	[_username release];
	[_hash release];
	[_startDate release];
	[_expirationDate release];
	
	[super dealloc];
}

- (MBLLicenseType)licenseType
{
	return _licenseType;
}
- (NSString *)username
{
	return _username;
}
- (NSString *)hash
{
	return _hash;
}
- (NSCalendarDate *)startDate
{
	return _startDate;
}
- (NSCalendarDate *)expirationDate
{
	return _expirationDate;
}

- (void)setStartDate:(NSCalendarDate *)date
{
	[date retain];
	[_startDate release];
	_startDate = date;
}
- (void)setExpirationDate:(NSCalendarDate *)date
{
	[date retain];
	[_expirationDate release];
	_expirationDate = date;
}

- (void)setUsername:(NSString *)username
{
	[username retain];
	[_username release];
	_username = username;
}

- (void)setHash:(NSString *)hash
{
	[hash retain];
	[_hash release];
	_hash = hash;
}

- (void)setLicenseType:(MBLLicenseType)type
{
	_licenseType = type;
}

- (BOOL)isValid
{
	return [_hash isEqual:[[_username dataUsingEncoding:NSUTF8StringEncoding] sha1HashAsString]];
}

- (id)initWithUsername:(NSString *)username key:(NSString *)key
{
	if (self = [super init])
	{
		[self setUsername:username];
		
		if ([key isValidKeyForName:username])
		{
			[self setStartDate:[NSCalendarDate dateWithString:@"2007-01-01" calendarFormat:@"%Y-%m-%d"]];
			[self setExpirationDate:[NSCalendarDate dateWithString:@"2106-01-01" calendarFormat:@"%Y-%m-%d"]];
			[self setHash:[[username dataUsingEncoding:NSUTF8StringEncoding] sha1HashAsString]];
			[self setLicenseType:MBLSingleUserLicenseType];
		}
		else
		{
			// Remove newlines
			NSMutableString *key_stripped = [key mutableCopy];
			[key_stripped replaceOccurrencesOfString:@"\n"
										  withString:@""
											 options:NSLiteralSearch
											   range:NSMakeRange(0, [key_stripped length])];	
			
			//NSLog(@"%@", key_stripped);
			
			NSArray *blacklist = [NSArray arrayWithObjects:nil];
			if ([blacklist containsObject:key_stripped])
			{
				NSLog(@"Blacklisted serial key. Please don't steal licenses.");
			}
			else
			{
				NSData *digest_as_utf8_data = [NSData dataWithBase64EncodedString:key_stripped];
				
				//NSLog(@"%@", digest_as_utf8_data);
				
				unsigned int data_size = [digest_as_utf8_data length];
				unsigned char *digest = (unsigned char *)[digest_as_utf8_data bytes];
				
				NSString *message;
				
				// Ladies 'n' gentlemen, our public key:
				unsigned char pub_key[] =
					/* public-new.pem (2048 bit)
					"-----BEGIN PUBLIC KEY-----\n"
					"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy8VHEi4ssrSgye7++WJp\n"
					"so7cXRxBTB7IHcVe/Mw1BXej1642XJi8V7xZ0j/dM1wvejmQchKtUzyrWBf57L0s\n"
					"oOmEzVq0tiOcxn8/XjIIxrGoqv4HTl+VT4xUo5YWrZgKBbm4tPKgK68NHgrLd/5P\n"
					"x0RYyWcitQRvbsSzUbyip/QbppJu6WAaV3WMysCDmY5PdkkZ95owmKvEiS3fxTSJ\n"
					"2X6pQ3V7C7oQZTTbYHELYZvQc50ydLQVq6ixqxaQjMnCwbRwiWLtrKKITdBm1gqp\n"
					"0hcGA+6CsD+3gY7c1Qf5kxxxRiTxddQBXun1Rj+RkJah9HQDXKIZnyEX9NG3i9Nh\n"
					"VQIDAQAB\n"
					"-----END PUBLIC KEY-----";
					*/
					"-----BEGIN PUBLIC KEY-----\n"
					"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDy7D+H/Ehq7vM1HgyowGTCC3nV\n"
					"jW7sS3sFRcJYHMDgq9k5FkuDhuw73aY3mUmwExKeB9zaPAA92NRPUeQzWD2PL4aS\n"
					"DcYc47B+BZqywf3XF9j5gFa4abknIPK9nDN7k8H3mVRFCrnHUPzkw+/60OqmPcGE\n"
					"2HvAjHPUikxV5bxJnQIDAQAB\n"
					"-----END PUBLIC KEY-----";
				
				BIO *a_bio;
				if (a_bio = BIO_new_mem_buf(pub_key,
											sizeof(pub_key)))
				{
					RSA *a_rsa_key = 0;
					if (PEM_read_bio_RSA_PUBKEY(a_bio, &a_rsa_key,
												NULL, NULL))
					{
						unsigned char *a_digest = (unsigned char *)malloc(data_size - 11);
						
						RSA_public_decrypt(RSA_size(a_rsa_key), digest,
										   a_digest, a_rsa_key, RSA_PKCS1_PADDING);
						
						NSData *decrypted = [NSData dataWithBytes:a_digest
														   length:64];
						//NSLog(@"Decrypted: (%@)", decrypted);
						message = [[NSString alloc] initWithData:decrypted
														 encoding:NSUTF8StringEncoding];
						//NSLog(@"%@", message);
						
						RSA_free(a_rsa_key);
						free(a_digest);
					}
					BIO_free(a_bio);
				}
				
				//NSLog(@"%@", message);
				
				NSString *theHash, *theExpirationDate, *theStartDate;
				NSScanner *theScanner = [NSScanner scannerWithString:message];
				if ([theScanner scanUpToString:@";" intoString:&theHash] &&
					[theScanner scanString:@";" intoString:NULL] &&
					[theScanner scanUpToString:@";" intoString:&theStartDate] &&
					[theScanner scanString:@";" intoString:NULL] &&
					[theScanner scanUpToString:@";" intoString:&theExpirationDate] &&
					[theScanner scanString:@";" intoString:NULL] &&
					[theScanner scanInt:&_licenseType])
				{
					/*
					 NSLog(@"%@, %@, %@, %d",
						   theHash,
						   theStartDate,
						   theExpirationDate,
						   _licenseType);
					 */

					[self setStartDate:[NSCalendarDate dateWithString:theStartDate calendarFormat:@"%Y-%m-%d"]];
					[self setExpirationDate:[NSCalendarDate dateWithString:theExpirationDate calendarFormat:@"%Y-%m-%d"]];
					[self setHash:theHash];
					
					/*
					 
					 NSLog(@"%@, %@, %@, %d",
						   _hash,
						   _startDate,
						   [_expirationDate descriptionWithCalendarFormat:@"%a %e %b %Y"],
						   _licenseType);
					 
					 [theHash release];
					 [theExpirationDate release];
					 [theStartDate release];
					 
					 NSLog(@"%d", [self validForUsername:@"Allan Odgaard"]);
					 */
				}
				[message release];
			}
			[key_stripped release];
		}
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:NSLocalizedString(@"Start date: %@, expiration date: %@, license type: %@", 
														@"Start date: %@, expiration date: %@, license type: %@"),
		[_startDate descriptionWithCalendarFormat:@"%Y-%m-%d"],
		[_expirationDate descriptionWithCalendarFormat:@"%Y-%m-%d"],
		[[self class] descriptionForLicenseType:_licenseType]];
}

+ (NSString *)descriptionForLicenseType:(MBLLicenseType)type
{
	switch (type)
	{
		case MBLSingleUserLicenseType:
			return NSLocalizedString(@"Single user license", @"Single user license");
		case MBLFamilyPackLicenseType:
			return NSLocalizedString(@"Family pack license", @"Family pack license");
		case MBLSiteLicenseType:
			return NSLocalizedString(@"Site license", @"Site license");
		case MBLEvaluationLicenseType:
			return NSLocalizedString(@"Evaluation license", @"Evaluation license");
		case MBLGiftLicenseType:
			return NSLocalizedString(@"Gift license", @"Gift license");
	}
	return nil;
}

+ (id)licenseForUsername:(NSString *)username key:(NSString *)key
{
	return [[[MBLLicense alloc] initWithUsername:username key:key] autorelease];
}

+ (int)minKeyLength
{
	return MBLLicenseMinKeyLength;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_username forKey:@"username"];
	[aCoder encodeObject:_hash forKey:@"hash"];
	[aCoder encodeObject:_startDate forKey:@"start_date"];
	[aCoder encodeObject:_expirationDate forKey:@"expiration_date"];
	[aCoder encodeInt:_licenseType forKey:@"license_type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init])
	{
		[self setUsername:[aDecoder decodeObjectForKey:@"username"]];
		[self setHash:[aDecoder decodeObjectForKey:@"hash"]];
		[self setExpirationDate:[aDecoder decodeObjectForKey:@"expiration_date"]];
		[self setStartDate:[aDecoder decodeObjectForKey:@"start_date"]];
		[self setLicenseType:[aDecoder decodeIntForKey:@"license_type"]];
	}
	return self;
}

@end
