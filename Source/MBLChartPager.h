//
//  MBLChartPager.h
//  MiniBatteryLogger
//
//  Created by delphine on 17-01-2008.
//  Copyright 2008 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MBLChartPager : NSView {

	int _currentPage;
	int _totalPages;
}

- (void)setCurrentPage:(int)page;
- (int)currentPage;
- (void)setTotalPages:(int)pages;
- (int)totalPages;

@end
