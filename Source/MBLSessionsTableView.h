//
//  MBLSessionsTableView.h
//  MiniBatteryLogger
//
//  Created by delphine on 25-01-2007.
//  Copyright 2006 Claudio Procida. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SessionsController.h"

@interface MBLSessionsTableView : NSTableView {
	
	IBOutlet SessionsController *sessionsController;
	
	int draggedRow;
}

- (int)draggedRow;
- (void)setDraggedRow:(int)row;

@end
