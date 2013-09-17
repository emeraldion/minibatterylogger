//
//  NSData+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 25-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "NSData+MBLUtils.h"


@implementation NSData (MBLUtils)

- (NSData *)md5Hash
{
	unsigned char* digest = MD5([self bytes], [self length], NULL);
	NSData *hash = [[NSData alloc] initWithBytes:digest length:MD5_DIGEST_LENGTH];
	return [hash autorelease];
}

- (NSString *)md5HashAsString
{
	unsigned char* digest = (unsigned char*)[[self md5Hash] bytes];
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
		digest[0], digest[1], 
		digest[2], digest[3],
		digest[4], digest[5],
		digest[6], digest[7],
		digest[8], digest[9],
		digest[10], digest[11],
		digest[12], digest[13],
		digest[14], digest[15]];
	// Already autoreleased object
	return s;
}

- (NSData *)sha1Hash
{
	unsigned char* digest = SHA1([self bytes], [self length], NULL);
	NSData *hash = [[NSData alloc] initWithBytes:digest length:SHA_DIGEST_LENGTH];
	return [hash autorelease];
}

- (NSString *)sha1HashAsString
{
	unsigned char* digest = (unsigned char*)[[self sha1Hash] bytes];
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
		digest[0], digest[1], 
		digest[2], digest[3],
		digest[4], digest[5],
		digest[6], digest[7],
		digest[8], digest[9],
		digest[10], digest[11],
		digest[12], digest[13],
		digest[14], digest[15],
		digest[16], digest[17],
		digest[18], digest[19]];
	// Already autoreleased object
	return s;
}

@end
