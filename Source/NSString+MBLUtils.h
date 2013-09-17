//
//  NSString+MBLUtils.h
//  MiniBatteryLogger
//
//  Created by delphine on 24-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <openssl/pem.h>
#import <openssl/rsa.h>
#import <openssl/bio.h>
#import "NSData+MBLUtils.h"
#import "base32.h"

@interface NSString (MBLUtils)

- (void)drawRoundedLabelAtPoint:(NSPoint)pt withAttributes:(NSDictionary *)fontAttributes backgroundColor:(NSColor *)bgColor;

/* Returns a string obtained inserting separator after every len characters of receiver */
- (NSString *)stringBySplittingChunksOfLength:(int)len separator:(NSString *)separator;

/* Verifies if the current string is a valid serial for the given name */
- (BOOL)isValidKeyForName:(NSString *)name;

@end
