//
//  MBLStarsView.h
//  MiniBatteryLogger
//
//  Created by delphine on 26-01-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MBLStarsView : NSView {

	float _value;
}

- (void)setFloatValue:(float)value;
- (float)floatValue;

@end
