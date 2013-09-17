//
//  MBLStarsView.m
//  MiniBatteryLogger
//
//  Created by delphine on 26-01-2007.
//  Copyright 2007 Claudio Procida. All rights reserved.
//

#import "MBLStarsView.h"

#define STAR_WIDTH 17
#define STAR_HEIGHT 17

#define MIN_VALUE 0.0
#define MAX_VALUE 5.0

static NSRect MBLStarsViewRect = {0, 0, 85, 17};

@implementation MBLStarsView

+ (void)initialize
{
	[self exposeBinding:@"floatValue"];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setFloatValue:(float)value
{
	if (value < MIN_VALUE)
	{
		value = MIN_VALUE;
	}
	else if (value > MAX_VALUE)
	{
		value = MAX_VALUE;
	}
	_value = value;
	[self setNeedsDisplay:YES];
}

- (float)floatValue
{
	return _value;
}

- (NSRect)bounds
{
	return MBLStarsViewRect;
}

- (void)drawRect:(NSRect)rect {
	NSImage *starsOff, *starsOn, *matteLayer;
	starsOff = [NSImage imageNamed:@"stars-off"];
	starsOn = [NSImage imageNamed:@"stars-on"];

	[starsOff drawAtPoint:NSZeroPoint
				 fromRect:[self bounds]
				operation:NSCompositeSourceOver
				 fraction:1.0];

	if (_value > MIN_VALUE)
	{
		NSRect onRect, remRect;
		NSDivideRect([self bounds], &onRect, &remRect, _value * [self bounds].size.width / MAX_VALUE, NSMinXEdge);

		matteLayer = [[NSImage alloc] initWithSize:onRect.size];
		[matteLayer lockFocus]; {
			[starsOn drawAtPoint:NSZeroPoint
						fromRect:[self bounds]
					   operation:NSCompositeSourceOver
						fraction:1.0];		
		} [matteLayer unlockFocus];
		
		[matteLayer drawAtPoint:NSZeroPoint
					   fromRect:onRect
					  operation:NSCompositeSourceOver
					   fraction:1.0];
		[matteLayer release];
	}
}

@end
