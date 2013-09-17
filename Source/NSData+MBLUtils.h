//
//  NSData+MBLUtils.h
//  MiniBatteryLogger
//
//  Created by delphine on 25-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <openssl/md5.h>
#import <openssl/sha.h>

@interface NSData (MBLUtils)

- (NSData *)md5Hash;
- (NSString *)md5HashAsString;

- (NSData *)sha1Hash;
- (NSString *)sha1HashAsString;

@end
