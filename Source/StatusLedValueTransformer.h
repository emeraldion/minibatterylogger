//
//  StatusLedValueTransformer.h
//  MiniBatteryLogger
//
//  Created by delphine on 18-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
	MBLStatusLedOnOffMode = 1,
	MBLStatusLedGoodBadMode
};

@interface StatusLedValueTransformer : NSValueTransformer {

	int _mode;
}

- (int)mode;
- (void)setMode:(int)mode;

- (id)initWithMode:(int)mode;

@end
