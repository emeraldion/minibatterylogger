//
//  SVController.h
//  MiniBatteryLogger
//
//  Created by delphine on 13-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MBLWearView.h"

@interface SVController : NSObject {
@private
	IBOutlet MBLWearView *wearView;
	IBOutlet NSArrayController *snapshotsController;
}

- (IBAction)open:(id)sender;

@end
