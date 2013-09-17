//
//  FlatColorView.m
//  MiniBatteryLogger
//
//  Created by delphine on 3-09-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import "FlatColorView.h"


@implementation FlatColorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:rect];
}

@end
