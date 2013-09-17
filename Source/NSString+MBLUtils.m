//
//  NSString+MBLUtils.m
//  MiniBatteryLogger
//
//  Created by delphine on 24-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "NSString+MBLUtils.h"


@implementation NSString (MBLUtils)

- (void)drawRoundedLabelAtPoint:(NSPoint)pt withAttributes:(NSDictionary *)attrs backgroundColor:(NSColor *)bgColor
{
	NSSize mySize = [self sizeWithAttributes:attrs];
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path appendBezierPathWithOvalInRect:NSMakeRect(pt.x,
													pt.y,
													mySize.height,
													mySize.height)];
	[path appendBezierPathWithOvalInRect:NSMakeRect(pt.x + mySize.width - mySize.height,
													pt.y,
													mySize.height,
													mySize.height)];
	[path appendBezierPathWithRect:NSMakeRect(pt.x + mySize.height / 2,
											  pt.y,
											  mySize.width - mySize.height,
											  mySize.height)];
	[bgColor set];
	[path fill];
	/*
	 [attrs setValue:[NSColor whiteColor]
			  forKey:NSForegroundColorAttributeName];
	 */
	[self drawAtPoint:pt
	   withAttributes:attrs];
}

- (NSString *)stringBySplittingChunksOfLength:(int)len separator:(NSString *)separator
{
	// If called with a length greater or equal to the receiver's length,
	// return the whole receiver
	if (len >= [self length])
	{
		return self;
	}
	
	NSMutableArray *chunks = [NSMutableArray array];
	int pieces = [self length] / len;
	int last_piece = [self length] % len;
	int i = 0;
	NSRange rng = NSMakeRange(0, len);
	while (i < pieces)
	{
		[chunks addObject:[self substringWithRange:rng]];
		rng.location += len;
		i++;
	}
	if (last_piece)
	{
		rng.length = last_piece;
		[chunks addObject:[self substringWithRange:rng]];
	}
	return [chunks componentsJoinedByString:separator];
}

- (BOOL)isValidKeyForName:(NSString *)name
{
	BOOL ret = NO;
	
	/**
	*	Verify that the contents of the string is a valid signed copy
	 *	of the data created from name, using RSA asymmetric cryptography
	 */
	
	// We reserve a list of blacklisted serial numbers to exclude
	// eventual leaked serials etc.
	NSArray *blacklist = [NSArray arrayWithObjects:
		/* Serial leaked by Peter Hacker (victor) */
		@"MBL-208-166-291",
		/* Wrong serial for Chuck C.arr :)) */
		@"MBL-OXIVMJ-7GSZU2-SDCTKT-CCG7UR-AAAABT-J3AA35-KEA",
		nil];
	
	if ([blacklist containsObject:self])
	{
		return NO;
	}
	
	NSRange prefixRange = [self rangeOfString:@"MBL-"];
	if (
		// Serial must have a given prefix...
		prefixRange.length > 0 &&
		// ...and a given syntax XXXX-XXXX-XXXX
		[self length] == 49
		)
	{		
		NSMutableString *temp = [[[self substringFromIndex:(prefixRange.location + prefixRange.length)] stringByAppendingString:@"="] mutableCopy];
		//NSLog(@"%@", temp);
		//NSLog(@"%d", [temp length]);
		
		// Eliminate all separator dashes from the serial key
		[temp replaceOccurrencesOfString:@"-"
							  withString:@""
								 options:NSLiteralSearch
								   range:NSMakeRange(0,[temp length])];
		//NSLog(@"%@", temp);
		
		// Generate NSData from serial
		NSData *own_encoded_data = [temp dataUsingEncoding:NSASCIIStringEncoding];
		
		// Decode serial data using base32
		unsigned char *data = [own_encoded_data bytes];
		int data_size = [own_encoded_data length];
		int outlen;
		char *own_plain_data = base32_decode(data,
											 data_size,
											 &outlen);
		
		//		NSLog(@"Dati in chiaro: %s", own_plain_data);
		//		NSLog(@"Lunghezza: %d", outlen);
		
		// Ladies 'n' gentlemen, our public key:
		unsigned char pub_key[] =
			"-----BEGIN PUBLIC KEY-----\n"
			"MCswDQYJKoZIhvcNAQEBBQADGgAwFwIQAKlAE1KDMbRv/s/OISKKqQIDAQAB\n"
			"-----END PUBLIC KEY-----";
		
		BIO *a_bio;
		if (a_bio = BIO_new_mem_buf(pub_key,
									sizeof(pub_key)))
		{
			RSA *a_rsa_key = 0;
			if (PEM_read_bio_RSA_PUBKEY(a_bio, &a_rsa_key,
										NULL, NULL))
			{
				//NSLog(@"%d", RSA_size(a_rsa_key) - 11);
				unsigned char *a_digest = (unsigned char *)malloc(RSA_size(a_rsa_key) - 11);
				
				RSA_public_decrypt(RSA_size(a_rsa_key), own_plain_data,
								   a_digest, a_rsa_key, RSA_PKCS1_PADDING);
				//NSLog(@"Decrypted: %s", a_digest);
				
				// Get decrypted data
				NSData *decrypted = [NSData dataWithBytes:a_digest
												   length:RSA_size(a_rsa_key) - 11];
				
				NSData *user_hash = [[[name dataUsingEncoding:NSASCIIStringEncoding] sha1Hash] subdataWithRange:NSMakeRange(0,4)];
				//NSLog(@"user_hash: %s", [user_hash bytes]);
				
				ret = [user_hash isEqualToData:decrypted];
				
				RSA_free(a_rsa_key);
				free(a_digest);
			}
			BIO_free(a_bio);
		}
		free(own_plain_data);
		[temp release];
	}
	
	return ret;	
}

@end
