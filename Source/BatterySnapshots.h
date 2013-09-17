//
//  BatterySnapshots.h
//  MiniBatteryLogger
//
//  Created by delphine on 13-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BatterySnapshot.h"

@interface BatterySnapshots : NSObject <NSCoding> {

	NSMutableArray *shots;
}

+ (NSString *)folderPath;
+ (id)snapshotsForBattery:(NSString *)name atIndex:(int)index;
/* Deprecated */
+ (id)snapshotsForIndex:(int)index;
/* Removes pre-1.7 snapshots forever */
+ (BOOL)removeSnapshotsForIndex:(int)index;

/* Returns an autoreleased, empty snapshots object */
+ (id)snapshots;

- (void)addShot:(id)shot;
- (int)count;
- (void)setShots:(NSMutableArray *)shots;
- (NSMutableArray *)shots;
- (id)shotAtIndex:(int)index;
- (void)saveToFileForBattery:(NSString *)name atIndex:(int)index;

@end