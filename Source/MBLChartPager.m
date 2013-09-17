//
//  MBLChartPager.m
//  MiniBatteryLogger
//
//  Created by delphine on 17-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import "MBLChartPager.h"

static float MBLChartPagerDiscDiameter = 8.0;
static float MBLChartPagerDiscSpacing = 4.0;

@implementation MBLChartPager

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _currentPage = 0;
		_totalPages = 1;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	{
		[[NSColor whiteColor] set];
		NSRectFill(rect);
		
		if (_totalPages > 1)
		{
			[[NSColor grayColor] set];
			NSBezierPath *circle;
			
			int page;
			float left = 2.0;
			for (page = 0; page < _totalPages; page++)
			{
				circle = [[NSBezierPath alloc] init];
				[circle appendBezierPathWithOvalInRect:NSMakeRect(left,
																  2.0,
																  MBLChartPagerDiscDiameter,
																  MBLChartPagerDiscDiameter)];
				[circle setLineWidth:1.0];
				if (page == _currentPage)
				{
					[circle fill];
				}
				[circle stroke];

				[circle release];
				left += MBLChartPagerDiscDiameter + MBLChartPagerDiscSpacing;
			}
		}
	}
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)setCurrentPage:(int)page
{
	_currentPage = (page > 0) ? page : 0;
	[self setNeedsDisplay:YES];
}
- (int)currentPage
{
	return _currentPage;
}
- (void)setTotalPages:(int)pages
{
	_totalPages = (pages > 0) ? pages : 0;
	[self setNeedsDisplay:YES];
}
- (int)totalPages
{
	return _totalPages;
}

- (void)awakeFromNib
{
	[self setTotalPages:10];
	[self setCurrentPage:5];
}

@end
