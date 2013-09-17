//
//  AOSegmentedCell.h
//  MiniBatteryLogger
//
//  Created by delphine on 27-08-2006.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define NSSegmentedCellAquaStyle 1    // Like the tabs in an NSTabView.
#define NSSegmentedCellMetalStyle 2    // Like the Safari and Finder buttons.


@interface AOSegmentedControl : NSSegmentedControl
{
}
@end

@interface NSSegmentedCell ( Private )
- (void)_setSegmentedCellStyle:(int)style;
@end
