//
//  MiniChartView.m
//  MiniBatteryLogger
//
//  Created by delphine on 11-06-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MiniChartView.h"


@implementation MiniChartView

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
	{
		hPad = 20.0;
		vPad = 20.0;
		drawScales = NO;
		//graphLineWidth = 3.0;
		//shouldDrawBubbles = YES;
	}
    return self;
}

/* Overridden to prevent tracking */

- (void)mouseDown:(NSEvent *)event
{
}

- (void)scrollWheel:(NSEvent *)event
{
}

@end
