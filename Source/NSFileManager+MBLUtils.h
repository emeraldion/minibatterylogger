//
//  NSFileManager+MBLUtils.h
//  MiniBatteryLogger
//
//  Created by delphine on 19-11-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (MBLUtils)

- (BOOL)emptyDirectoryAtPath:(NSString *)path;

@end
