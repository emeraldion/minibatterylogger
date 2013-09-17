//
//  SharedArchive.h
//  MiniBatteryLogger
//
//  Created by delphine on 1-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SharedArchive : NSObject {

}

+ (void)archiveEntryForBattery:(NSString *)uid;

@end
