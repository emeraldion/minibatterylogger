//
//  MBLBatteryManagersTableView.h
//  MiniBatteryLogger
//
//  Created by delphine on 16-04-2007.
//  Copyright 2007 Claudio Procida - Emeraldion Lodge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MBLBatteryManagersTableView : NSTableView {

	NSIndexSet *draggedRows;
	
	BOOL usesGradientSelection;
	BOOL selectionGradientIsContiguous;
	BOOL usesDisabledGradientSelectionOnly;
	BOOL hasBreakBetweenGradientSelectedRows;
	
	//NSMutableDictionary *regionList;
}

/* Useful for delegate when deciding how to colour text */
- (NSIndexSet *)draggedRows;

	// Gradient selection methods
	/* Sets whether the outline view should use gradient selection bars. */
- (void)setUsesGradientSelection:(BOOL)flag;
- (BOOL)usesGradientSelection;

	/* Sets whether gradient selections should be contiguous across multiple
	rows. (iTunes and Mail don't have this, but I think it looks better.) */
- (void)setSelectionGradientIsContiguous:(BOOL)flag;
- (BOOL)selectionGradientIsContiguous;

	/* Sets whether the selection should always look disabled (grey), even
	when the outline view has the focus (like in Mail) */
- (void)setUsesDisabledGradientSelectionOnly:(BOOL)flag;
- (BOOL)usesDisabledGradientSelectionOnly;

	/* Sets whether selected rows have a pixel gap between them that is the
	background colour rather than the selection colour */
- (void)setHasBreakBetweenGradientSelectedRows:(BOOL)flag;
- (BOOL)hasBreakBetweenGradientSelectedRows;

@end
